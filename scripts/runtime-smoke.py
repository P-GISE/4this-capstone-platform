import json
import os
import secrets
import subprocess
from http.cookies import SimpleCookie
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

BASE = "http://127.0.0.1:3401"
results = []
if os.environ.get("GITHUB_ACTIONS") != "true":
    raise SystemExit("Synthetic runtime writes are restricted to the isolated GitHub CI job")

class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, request, response, code, message, headers, newurl):
        return None

opener = urllib.request.build_opener(NoRedirect)
cookie = None

def probe(path, expected, method="GET", origin=None, body=None, authenticated=False):
    request = urllib.request.Request(BASE + path, data=body, method=method)
    if origin:
        request.add_header("Origin", origin)
    if authenticated:
        request.add_header("Cookie", cookie)
    if body:
        request.add_header("Content-Type", "application/x-www-form-urlencoded")
    try:
        with opener.open(request, timeout=15) as response:
            status = response.status
            headers = response.headers
    except urllib.error.HTTPError as error:
        status = error.code
        headers = error.headers
    results.append({"path": path, "method": method, "status": status, "expected": expected})
    Path("runtime-smoke.json").write_text(json.dumps(results, indent=2), encoding="utf-8")
    assert status == expected, f"{path}: {status} != {expected}"
    return headers

def sql(statement):
    result = subprocess.run(["docker", "compose", "exec", "-T", "db", "sh", "-c",
        'MYSQL_PWD="$MARIADB_PASSWORD" exec mariadb -u"$MARIADB_USER" "$MARIADB_DATABASE" -N -e "$1"', "sh", statement],
        capture_output=True, text=True, timeout=20)
    assert result.returncode == 0, "Synthetic database assertion failed"
    return result.stdout.strip()

probe("/health", 200)
probe("/auth/login", 200)
probe("/auth/login", 403, "POST", "https://untrusted.example.invalid", b"")
probe("/auth/login", 403, "POST", body=b"")
probe("/admin/users", 403)
probe("/ai/test-questions", 404)
probe("/ai/update-question-user-id", 404)
probe("/auth/register", 503, "POST", "http://localhost:3401", b"role=STUDENT")
probe("/ai/ask-json", 503, "POST", "http://localhost:3401", b"")
assert sql("SELECT COUNT(*) FROM users") == "0", "Runtime must begin with an empty user table"
password = secrets.token_urlsafe(24)
payload = json.dumps({"confirmation": "fresh-fourthis", "username": "ci-admin",
                     "password": password, "email": "ci-admin@example.invalid"})
bootstrap = subprocess.run(["docker", "compose", "exec", "-T", "app", "java", "-cp",
    "/usr/local/tomcat/webapps/ROOT/WEB-INF/classes:/usr/local/tomcat/webapps/ROOT/WEB-INF/lib/*",
    "com.example.test.config.AdminBootstrap"], input=payload, capture_output=True, text=True, timeout=30)
assert bootstrap.returncode == 0 and "administrator_created=true" in bootstrap.stdout, "Administrator bootstrap failed"
headers = probe("/auth/login", 302, "POST", "http://localhost:3401",
    urllib.parse.urlencode({"username": "ci-admin", "password": password}).encode())
jar = SimpleCookie()
for value in headers.get_all("Set-Cookie", []): jar.load(value)
session = jar.get("FOURTHIS_SESSION")
assert session is not None and session["secure"] and session["httponly"] and session["samesite"].lower() == "lax", "Secure session attributes missing"
cookie = "FOURTHIS_SESSION=" + session.value
probe("/dashboard", 200, authenticated=True)
probe("/admin/users", 200, authenticated=True)
sql("INSERT INTO users(username,password,name,email,role,is_email_verified,status) SELECT 'ci-student',password,'Synthetic student','ci-student@example.invalid','STUDENT',true,true FROM users WHERE username='ci-admin'")
sql("INSERT INTO student_profiles(user_id,student_id) SELECT id,'ci-student' FROM users WHERE username='ci-student'")
form = {"projectName": "Synthetic CI project", "projectDescription": "Synthetic CI only",
        "teamLeaderId": "ci-admin", "teamLeaderName": "관리자", "memberIds": "ci-student", "memberNames": "Synthetic student"}
probe("/projects/create", 200, "POST", "http://localhost:3401", urllib.parse.urlencode(form).encode(), True)
assert sql("SELECT COUNT(*) FROM projects") == "1", "Project creation did not persist"
assert sql("SELECT COUNT(*) FROM project_members") == "2", "Project membership did not persist"
probe("/projects/1", 200, authenticated=True)
probe("/equipment/list", 200, authenticated=True)
probe("/notice/list", 200, authenticated=True)
for service in ("app", "db"):
    container = subprocess.check_output(["docker", "compose", "ps", "-q", service], text=True).strip()
    log_driver = subprocess.check_output(["docker", "inspect", "--format", "{{.HostConfig.LogConfig.Type}}", container], text=True).strip()
    assert log_driver == "none", "Runtime Docker log persistence must be disabled"
logging_config = subprocess.run(["docker", "compose", "exec", "-T", "app", "sh", "-c",
    "! grep -q 'AccessLogValve' /usr/local/tomcat/conf/server.xml && ! grep -q 'FileHandler' /usr/local/tomcat/conf/logging.properties"],
    capture_output=True, timeout=15)
assert logging_config.returncode == 0, "Tomcat file/access log configuration must be disabled"
summary = {"passed": len(results), "body_saved": False, "cookies_saved": False,
           "bootstrap": True, "session_roundtrip_manual_cookie_header": True,
           "secure_cookie_attributes": True, "project_count": 1, "member_count": 2,
           "docker_log_persistence_disabled": True, "tomcat_file_access_logs_disabled": True}
Path("runtime-smoke-summary.json").write_text(json.dumps(summary, indent=2), encoding="utf-8")
print(json.dumps(summary))
