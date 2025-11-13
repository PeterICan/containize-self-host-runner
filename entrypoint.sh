#!/bin/bash

echo abababababa
# # 檢查必要的環境變數
# if [ -z "${GITHUB_URL}" ]; then
#   echo "錯誤：未設定 GITHUB_URL 環境變數。"
#   exit 1
# fi

# if [ -z "${GITHUB_TOKEN}" ]; then
#   echo "錯誤：未設定 GITHUB_TOKEN 環境變數。"
#   exit 1
# fi

# # 移除舊的 runner 註冊 (如果存在的話)
# # 這很重要，尤其是在重新啟動或更新容器時
# echo "正在嘗試移除舊的 runner 註冊..."
# ./config.sh remove --unattended --token "${GITHUB_TOKEN}" --url "${GITHUB_URL}" || true
# echo "舊的 runner 註冊移除完成 (如果存在的話)。"

# # 配置並註冊 runner
# echo "正在配置 runner..."
# ./config.sh --url "${GITHUB_URL}" --token "${GITHUB_TOKEN}" --name "$(hostname)" --unattended --replace

# # 啟動 runner
# echo "正在啟動 runner..."
# exec ./run.sh


# ./config.sh --url https://github.com/PeterICan/containize-self-host-runner --token BI4VMW4F7DRT5XBC3QU2HO3ILERXW