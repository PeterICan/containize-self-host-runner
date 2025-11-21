#!/bin/bash

# 取得腳本所在目錄
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# 切換到專案根目錄
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT" || exit 1
echo "-> 工作目錄已切換至: $(pwd)"

# 1. 取得最新 Runner 下載連結
echo "-> 正在查詢最新版 GitHub Runner..."
LATEST_RELEASE_URL="https://api.github.com/repos/actions/runner/releases/latest"
DOWNLOAD_URL=$(curl -s "$LATEST_RELEASE_URL" | jq -r '.assets[] | select(.name | test("actions-runner-linux-x64-[0-9.]+\\.tar\\.gz$")) | .browser_download_url' | head -n 1)

if [ -z "$DOWNLOAD_URL" ]; then
    echo "錯誤: 無法找到 Linux x64 版本的 Runner 下載連結。"
    exit 1
fi

FILENAME=$(basename "$DOWNLOAD_URL")
echo "-> 最新版本下載連結: $DOWNLOAD_URL"
echo "-> 檔案名稱: $FILENAME"

# 2. 準備安裝目錄
RUNNER_DIR="actions-runner"
if [ ! -d "$RUNNER_DIR" ]; then
    mkdir "$RUNNER_DIR"
    echo "-> 建立目錄: $RUNNER_DIR"
else
    echo "-> 目錄 $RUNNER_DIR 已存在。"
fi

cd "$RUNNER_DIR"

# 3. 下載 Runner
if [ ! -f "$FILENAME" ]; then
    echo "-> 正在下載 Runner..."
    curl -o "$FILENAME" -L "$DOWNLOAD_URL"
else
    echo "-> 檔案 $FILENAME 已存在，跳過下載。"
fi

# 4. 解壓縮
echo "-> 正在解壓縮..."
tar xzf "./$FILENAME"

echo "-> Runner 下載與解壓縮完成。"

echo "-> Runner 清理壓縮檔..."
cd..
rm $FILENAME
echo "-> Runner 清理壓縮檔完成"

