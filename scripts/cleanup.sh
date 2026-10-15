#!/usr/bin/env bash
# Chỉ dọn container Lab 2 do docker-up.sh quản lý; giữ image để chạy lại.
set -euo pipefail
ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/scripts/env.sh"
if docker container inspect lab2-app >/dev/null 2>&1; then
    owner=$(docker inspect --format '{{index .Config.Labels "vn.devops.lab"}}' lab2-app)
    [ "$owner" = 'lab2' ] || { echo 'FAIL: lab2-app is not managed by this lab script.'; exit 1; }
    docker stop lab2-app
    docker rm lab2-app
else
    echo 'No lab2-app container to remove.'
fi
echo 'Cleanup complete. Image devops-lab2-app retained for reuse.'
