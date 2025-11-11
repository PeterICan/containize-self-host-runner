# 使用 Ubuntu 做為基礎映像檔，因為 GitHub Runner 官方支援 Ubuntu
FROM ubuntu:22.04

# 設定工作目錄
WORKDIR /actions-runner

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


# 設定環境變數
# ACTIONS_RUNNER_VERSION：指定要下載的 GitHub Runner 版本
# RUNNER_ALLOW_RUNASROOT：允許 Runner 以 root 身份執行 (在容器中通常需要)
ENV ACTIONS_RUNNER_VERSION="2.317.0"
ENV RUNNER_ALLOW_RUNASROOT="1"

# 下載並解壓縮 GitHub Runner
RUN curl -o actions-runner-linux-x64-${ACTIONS_RUNNER_VERSION}.tar.gz -L "https://github.com/actions/runner/releases/download/v${ACTIONS_RUNNER_VERSION}/actions-runner-linux-x64-${ACTIONS_RUNNER_VERSION}.tar.gz" \
    && tar xzf actions-runner-linux-x64-${ACTIONS_RUNNER_VERSION}.tar.gz

# 清理下載的 tar 檔案
RUN rm actions-runner-linux-x64-${ACTIONS_RUNNER_VERSION}.tar.gz

# 複製啟動腳本到容器中
COPY entrypoint.sh .

# 設定執行權限
RUN chmod +x entrypoint.sh

# 當容器啟動時執行 entrypoint.sh
ENTRYPOINT ["./entrypoint.sh"]