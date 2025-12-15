# 使用 Ubuntu 做為基礎映像檔，因為 GitHub Runner 官方支援 Ubuntu
FROM ubuntu:22.04

# 設定工作目錄
WORKDIR /

# 安裝必要的依賴項
# curl 用於下載 GitHub Runner 套件
# git 用於從 GitHub clone 儲存庫
# jq 用於解析 JSON 數據 (在某些進階設定中可能用到)
# libicu-dev 用於國際化支援 (GitHub Runner 的依賴)
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    curl \
    git \
    jq \
    libicu-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*
# 使用 Ubuntu 做為基礎映像檔，因為 GitHub Runner 官方支援 Ubuntu


# 設定環境變數
# RUNNER_ALLOW_RUNASROOT：允許 Runner 以 root 身份執行 (在容器中通常需要)
ENV RUNNER_ALLOW_RUNASROOT="1"

# 複製 action 目錄 (包含下載與配置腳本)
COPY action ./action

# 檢查環境是否有 action 目錄
RUN if [ ! -d "action" ]; then \
    echo "Error: action 資料夾不存在." && \
    exit 1; \
    fi; \
    echo "action directory found." && \
    echo "Containing Scripts." && \
    ls -al ./action && \
    echo "-------------------------"


# 將腳本轉換為 Unix 格式以避免行結尾問題
RUN apt-get update && apt-get install -y dos2unix && \
    dos2unix action/*.sh

# 賦予腳本執行權限並檢查
RUN chmod +x action/*.sh && ls -l action/

# 執行下載腳本 (建置階段下載 Runner)
RUN ./action/download_runner.sh && \
    if [ $? -ne 0 ]; then \
    echo "Error: download_runner.sh failed."; \
    exit 1; \
    fi

ENV ACTION_RUNNER_FOLDER_NAME="actions_runner"
# 複製啟動腳本到容器中
COPY entrypoint.sh .

# 將腳本轉換為 Unix 格式以避免行結尾問題
RUN dos2unix entrypoint.sh

# 設定執行權限
RUN chmod +x entrypoint.sh

# 當容器啟動時執行 entrypoint.sh
ENTRYPOINT ["./entrypoint.sh"]