#!/bin/bash

# 確保腳本出錯時停止執行
set -e

echo "--------------------------------------------------"
echo "🚀 Starting GitHub Self-Hosted Runner Container"
echo "--------------------------------------------------"

# 1. 配置 Runner
# 呼叫 action/config_runner.sh 進行動態註冊
echo "-> Configuring Runner..."
# 腳本位於 /action 目錄下 (因為 Dockerfile COPY action ./action 且 WORKDIR /)
if [ -f "/action/config_runner.sh" ]; then
    source /action/config_runner.sh
else
    echo "錯誤: 找不到 /action/config_runner.sh"
    exit 1
fi

# 2. 啟動 Runner
echo "--------------------------------------------------"
echo "🏃 Starting Runner Service..."
echo "--------------------------------------------------"

# 定義清理函數 (當容器停止時執行)
cleanup() {
    echo "-> Stopping Runner..."
    # 這裡可以加入反註冊邏輯，例如 ./config.sh remove --token ...
    # 但因為 Token 是短期的，可能需要重新取得 Token 才能移除，或是使用 PAT
    echo "-> Container stopped."
}

# 捕捉 SIGINT 和 SIGTERM 信號
trap 'cleanup; exit 130' SIGINT
trap 'cleanup; exit 143' SIGTERM

# 啟動 Runner
./run.sh & 
RUNNER_PID=$!

# 等待 Runner 結束
wait $RUNNER_PID