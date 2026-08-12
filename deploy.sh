#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/starikam/shvirtd-example-python.git"
TARGET_DIR="/opt/shvirtd-example-python"

command -v git >/dev/null || { echo "git не установлен"; exit 1; }
docker compose version >/dev/null 2>&1 || { echo "нужен docker с compose-плагином"; exit 1; }

if [ -d "$TARGET_DIR/.git" ]; then
  echo ">>> Репозиторий уже есть, обновляю: $TARGET_DIR"
  git -C "$TARGET_DIR" pull --ff-only
else
  echo ">>> Клонирую $REPO_URL в $TARGET_DIR"
  git clone "$REPO_URL" "$TARGET_DIR"
fi

cd "$TARGET_DIR"

echo ">>> Запускаю проект"
docker compose up -d --build

echo ">>> Состояние сервисов:"
docker compose ps

echo ">>> Проверка:"
for i in $(seq 1 30); do
  if curl -sfL -m 5 http://127.0.0.1:8090 >/dev/null 2>&1; then
    echo -n "OK: "; curl -sL http://127.0.0.1:8090; echo
    exit 0
  fi
  sleep 2
done

echo "Сервис не ответил за 60 секунд, смотрите: docker compose logs"
exit 1
