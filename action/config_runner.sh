#!/bin/bash

# 取得腳本所在目錄
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# 切換到專案根目錄
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT" || exit 1
echo "-> 工作目錄已切換至: $(pwd)"

# 1. 取得 Token
echo "-> 正在取得 Runner 註冊 Token..."
source "$SCRIPT_DIR/get_token.sh"

if [ -z "$TOKEN" ]; then
    echo "錯誤: 無法取得 Token (變數 TOKEN 為空)。"
    exit 1
fi

echo "-> Token 取得成功。"

# 2. 配置 Runner
echo "-> 正在配置 Runner..."

# 檢查 config.sh 是否存在 (假設在 actions-runner 目錄下)
# 注意：在 Docker 環境中，WORKDIR 通常已經是 /actions-runner，所以 config.sh 應該在當前目錄
# 但為了相容本地測試，我們檢查 actions-runner 子目錄
if [ -d "actions-runner" ]; then
    cd actions-runner
fi

if [ ! -f "./config.sh" ]; then
    echo "錯誤: 在 $(pwd) 找不到 config.sh。"
    echo "請確認 Runner 是否已下載並解壓縮。"
    exit 1
fi

# 嘗試從 REPO_URL (API) 還原 HTML URL
# 移除 "api." 和 "/repos"，移除尾部的 "/actions/runners/registration-token"
CONFIG_URL=$(echo "$REPO_URL" | sed 's|api.github.com/repos|github.com|' | sed 's|/actions/runners/registration-token||')

echo "   Config URL: $CONFIG_URL"

./config.sh \
    --url "$CONFIG_URL" \
    --token "$TOKEN" \
    --name "runner-$(hostname)" \
    --unattended \
    --replace

echo "-> 配置完成！"
