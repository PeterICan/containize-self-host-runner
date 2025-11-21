#!/bin/bash

# 檢查必要環境變數
# REPO_URL 已內建
REPO_URL="https://api.github.com/repos/PeterICan/containize-self-host-runner/actions/runners/registration-token"
echo $PAT
if [ -z "$PAT" ]; then
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
    SETUP_PAT_PATH="$SCRIPT_DIR/setup_env.sh"
    PAT_FILE="$SCRIPT_DIR/../PAT.txt"
    source $SETUP_PAT_PATH
    if [ -z "$PAT" ]; then
    echo "錯誤: 未設定 PAT 環境變數"
    exit 1
    fi
fi

echo "-> 正在從 GitHub API 取得註冊 Token..."
echo "   Repo: $REPO_URL"

# 呼叫 GitHub API
# 注意：GitHub API 對於 Self-hosted runner registration token 的端點是 /actions/runners/registration-token
RESPONSE=$(curl -s -X POST -H "Authorization: token $PAT" \
    -H "Accept: application/vnd.github.v3+json" \
    "$REPO_URL")

# 解析 Token
TOKEN=$(echo "$RESPONSE" | jq -r .token)

if [ "$TOKEN" == "null" ] || [ -z "$TOKEN" ]; then
    echo "錯誤: 無法取得 Token。"
    echo "API 回應: $RESPONSE"
    exit 1
fi

echo "成功取得 Token: $TOKEN"
