#!/bin/bash

# 確保腳本出錯時停止執行
set -e

echo "--------------------------------------------------"
echo "🚀 Starting GitHub Self-Hosted Runner Container"
echo "--------------------------------------------------"

# # 1. 配置 Runner
# # 呼叫 action/config_runner.sh 進行動態註冊
# echo "-> Configuring Runner..."
# # 腳本位於 /action 目錄下 (因為 Dockerfile COPY action ./action 且 WORKDIR /)
# if [ -f "/action/config_runner.sh" ]; then
#     source /action/config_runner.sh
# else
#     echo "錯誤: 找不到 /action/config_runner.sh"
#     exit 1
# fi

if [ -d "actions-runner" ]; then
    cd actions-runner
fi

if [ ! -f "./config.sh" ]; then
    echo "錯誤: 在 $(pwd) 找不到 config.sh。"
    echo "請確認 Runner 是否已下載並解壓縮。"
    exit 1
fi

# 取得 just-in-time config
echo $PAT
if [ -z "$PAT" ]; then
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
    SETUP_PAT_PATH="$SCRIPT_DIR/../action/setup_env.sh"
    PAT_FILE="$SCRIPT_DIR/../PAT.txt"
    source $SETUP_PAT_PATH
    if [ -z "$PAT" ]; then
    echo "錯誤: 未設定 PAT 環境變數"
    exit 1
    fi
fi

RUNNER_NAME=runner-$(hostname)
RESPONSE=$(curl -L \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $PAT" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/PeterICan/containize-self-host-runner/actions/runners/generate-jitconfig \
  -d '{"name":"'"$RUNNER_NAME"'","runner_group_id": 1,"labels": ["self-hosted","X64"],"org": "PeterICan"}')

if [ -z "$RESPONSE" ]; then
    echo "錯誤: 無法取得 JIT 配置。"
    exit 1
fi

echo "-> Response received."
echo "Response: $RESPONSE"
echo "--------------------------------------------------"

# 提取 encoded_jit_config
ENCODED_CONFIG=$(echo "$RESPONSE" | jq -r '.encoded_jit_config')

if [ -z "$ENCODED_CONFIG" ]; then
    echo "錯誤: 無法提取 encoded_jit_config。"
    exit 1
fi

echo "-> JIT 配置已取得。"
echo "Encoded Config: $ENCODED_CONFIG"
echo "--------------------------------------------------"

# 取得 remove token
REMOVE_RESPONSE=$(curl -L \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $PAT" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/PeterICan/containize-self-host-runner/actions/runners/remove-token)

if [ -z "$REMOVE_RESPONSE" ]; then
    echo "錯誤: 無法取得移除 Token。"
    exit 1
fi
REMOVE_TOKEN=$(echo "$REMOVE_RESPONSE" | jq -r '.token')
if [ -z "$REMOVE_TOKEN" ]; then
    echo "錯誤: 無法提取移除 Token。"
    exit 1
fi
echo "-> Remove token 已取得。"
echo "Remove Token: $REMOVE_TOKEN"
echo "--------------------------------------------------"

# 2. 啟動 Runner
echo "--------------------------------------------------"
echo "🏃 Starting Runner Service..."
echo "--------------------------------------------------"

# 定義清理函數 (當容器停止時執行)
cleanup() {
    echo "-> Stopping Runner..."

    # 讀取 PAT 和 Runner 名稱
    if [ -f "/PAT.txt" ]; then
        PAT=$(cat /PAT.txt)
    else
        echo "錯誤: 找不到 PAT.txt"
        exit 1
    fi

    # 使用 GitHub API 反註冊 Runner
    echo "Container stopping, removing runner..."
    # 這裡需要傳入移除 Token，通常需要透過環境變數傳入或在啟動時預先取得。
    ./config.sh remove --token "$REMOVE_TOKEN"

    echo "-> Container stopped."
}

# 捕捉 SIGINT 和 SIGTERM 信號
trap 'cleanup; exit 130' SIGINT
trap 'cleanup; exit 143' SIGTERM

# 啟動 Runner
./run.sh --jitconfig "$ENCODED_CONFIG" &
RUNNER_PID=$!

# 等待 Runner 結束
wait $RUNNER_PID