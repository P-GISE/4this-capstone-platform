import json
import urllib.error
import urllib.request
from pathlib import Path

BASE = "http://127.0.0.1:3401"
results = []

def probe(path, expected, method="GET", origin=None, body=None):
    request = urllib.request.Request(BASE + path, data=body, method=method)
    if origin:
        request.add_header("Origin", origin)
    try:
        with urllib.request.urlopen(request, timeout=15) as response:
            status = response.status
    except urllib.error.HTTPError as error:
        status = error.code
    results.append({"path": path, "method": method, "status": status, "expected": expected})
    Path("runtime-smoke.json").write_text(json.dumps(results, indent=2), encoding="utf-8")
    assert status == expected, f"{path}: {status} != {expected}"

probe("/health", 200)
probe("/auth/login", 200)
probe("/auth/login", 403, "POST", "https://untrusted.example.invalid", b"")
probe("/auth/login", 403, "POST", body=b"")
probe("/admin/users", 403)
probe("/ai/test-questions", 404)
probe("/ai/update-question-user-id", 404)
print(json.dumps({"passed": len(results), "body_saved": False, "cookies_saved": False}))
