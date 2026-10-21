#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/scripts/env.sh"
cd "$ROOT_DIR"
PASS=0
FAIL=0
check() {
    local name="$1"
    shift
    if "$@"; then
        printf 'PASS: %s\n' "$name"
        PASS=$((PASS + 1))
    else
        printf 'FAIL: %s\n' "$name"
        FAIL=$((FAIL + 1))
    fi
}
image_exists() { docker image inspect devops-lab2-app >/dev/null; }
container_ready() { [ "$(docker inspect --format '{{.State.Running}} {{.State.Health.Status}}' lab2-app)" = 'true healthy' ]; }
echo '=== VERIFY — LAB 2 ==='
check 'Toolchain versions + Docker Engine' bash devops-check.sh
for file in setup-dev-env.sh setup-dev-env.ps1 Dockerfile server.js package.json package-lock.json .dockerignore; do
    check "$file exists" test -f "$file"
done
for dir in src tests docs screenshots; do check "$dir/ exists" test -d "$dir"; done
check 'Docker image exists' image_exists
check 'Container running and healthy' container_ready
check 'HTTP 200 + JSON fields + Linux/Node 18 inside Docker' docker exec lab2-app node -e '
const http = require("http");
http.get("http://127.0.0.1:3000", res => {
  let data = "";
  res.on("data", chunk => data += chunk);
  res.on("end", () => {
    try {
      const body = JSON.parse(data);
      if (res.statusCode !== 200 || !res.headers["content-type"].includes("application/json") ||
          body.message !== "Hello from Docker!" || body.lab !== "DevOps Lab 2 — Lean Principle" ||
          body.platform !== "linux" || !/^v18\./.test(body.node_version) ||
          !Number.isFinite(Date.parse(body.timestamp))) throw new Error("Unexpected API response");
      console.log(JSON.stringify(body, null, 2));
    } catch (error) { console.error(error.message); process.exitCode = 1; }
  });
}).on("error", error => { console.error(error.message); process.exitCode = 1; });'
check 'Host can reach published port 3000' curl --fail --silent --show-error --max-time 10 http://localhost:3000
echo
for file in docs/toolchain-map.svg docs/calms-assessment.md ho_ten_mssv.txt; do
    check "$file exists" test -s "$file"
done
for file in 01-toolchain-check.png 02-automation-script.png 03-docker-build.png 04-docker-run-curl.png 05-toolchain-map.png 06-calms-assessment.png; do
    check "screenshots/$file exists" test -s "screenshots/$file"
done
printf 'RESULT: %s PASS, %s FAIL\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
