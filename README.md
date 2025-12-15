# 🐳 Containerized GitHub Self-Hosted Runner

## 🎯 專案目標

將 GitHub Actions Self-Hosted Runner 容器化，提供**乾淨、隔離、可擴展**的 CI/CD 執行環境。容器啟動時動態註冊 Runner，實現**臨時性**或**即時性**的執行。

## 💡 核心挑戰與解法

| 挑戰 | 解法 |
| :--- | :--- |
| **註冊 Token 時效性** | 啟動腳本 (`start.sh`) 動態呼叫 GitHub API 取得 Token |
| **環境隔離** | 每個 Runner 在獨立容器中執行，完成後即銷毀 |
| **權限管理** | 使用環境變數傳遞長期 PAT，避免硬編碼 |

## 🚀 快速開始

### Step 1: 建立 PAT 憑證

在 GitHub 建立具 **`workflow`** 權限的 Personal Access Token (PAT)，用於 API 調用。

### Step 2: 撰寫 Dockerfile

定義 Runner 容器環境：

```dockerfile
FROM ubuntu:latest

# 安裝依賴
RUN apt-get update && \
    apt-get install -y curl git jq && \
    rm -rf /var/lib/apt/lists/*

# 下載 GitHub Runner
RUN mkdir /actions-runner && cd /actions-runner && \
    curl -o actions-runner.tar.gz -L "https://github.com/actions/runner/releases/download/v2.316.0/actions-runner-linux-x64-2.316.0.tar.gz" && \
    tar xzf actions-runner.tar.gz

# 複製啟動腳本
COPY start.sh /actions-runner/
WORKDIR /actions-runner

ENTRYPOINT ["/actions-runner/start.sh"]
```