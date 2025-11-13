#!/bin/bash
# 假設 REPO_URL, RUNNER_PAT, RUNNER_NAME 等變數已透過 docker run -e 傳入

# 1. 呼叫 GitHub REST API 取得短期註冊 Token
echo "-> 正在從 GitHub API 取得註冊 Token..."

REG_TOKEN=$(curl -s -X POST -H "Authorization: token $RUNNER_PAT" \
    -H "Accept: application/vnd.github.v3+json" \
    "$REPO_URL/actions/runners/registration-token" \
    | jq -r .token)

if [ -z "$REG_TOKEN" ]; then
    echo "錯誤: 無法取得註冊 Token。請檢查 PAT 權限和 REPO_URL。"
    exit 1
fi

# 2. 執行配置 (使用動態取得的 REG_TOKEN)
echo "-> 正在配置 Runner..."
./config.sh \
    --url "$REPO_URL" \
    --token "$REG_TOKEN" \
    --name "$RUNNER_NAME" \
    --labels "docker,ubuntu-runner" \
    --unattended \
    --replace

# 3. 啟動 Runner 服務並保持運行
echo "-> Runner 啟動並等待 Job..."
./run.sh & wait $!

# (可選) 增加反註冊邏輯
# 在容器關閉前執行反註冊，保持 GitHub Runner 列表的乾淨
# ./config.sh remove --token "$REG_TOKEN"