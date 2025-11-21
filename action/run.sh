#!/bin/bash

# 取得腳本所在目錄
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# 切換到專案根目錄
cd "$PROJECT_ROOT" || exit 1

echo "-> 正在使用 Docker Compose 建置並啟動 Runner..."

# 使用 docker-compose 啟動
# -p 指定專案名稱
# -d 背景執行
# --build 強制重新建置映像檔
docker-compose -p self_host-runner_test up -d --build

echo "-> 容器已啟動，請使用 'docker-compose logs -f' 查看日誌。"