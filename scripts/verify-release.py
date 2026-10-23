import pathlib
import sys

script = pathlib.Path(__file__).with_name("deploy-app.sh").read_text()
validator = script.split("<<'PY'\n", 1)[1].split("\nPY\n", 1)[0]
exec(compile(validator, "deploy-app-release-contract", "exec"))
print("release_archive_contract_verified=true")
