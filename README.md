# 🐳 Containerized GitHub Self-Hosted Runner 習作

## 🎯 專案目標 (Goal)

本專案旨在實現 GitHub Actions Self-Hosted Runner 的容器化，以提供一個**乾淨、隔離、可擴展且具備彈性**的 CI/CD 執行環境。

核心目標是將 Runner 封裝在 Docker 容器中，並在容器啟動時（Runtime）完成動態註冊，使其成為一個 **Ephemeral (臨時性)** 或 **Just-in-Time (JIT)** 的 Runner。

## 💡 核心挑戰與解決方案

| 挑戰 (Contradiction) | 解決方案 (The Solution) |
| :--- | :--- |
| **動態註冊：** Runner 註冊 Token (Registration Token) 具有時效性，無法寫死在 Docker 映像檔中。 | **REST API 呼叫：** 容器啟動腳本 (`start.sh`) 在 Runner 服務啟動前，動態呼叫 GitHub REST API 取得短期註冊 Token。 |
| **環境隔離：** 避免 Job 之間的環境污染。 | **容器化執行：** 每個 Runner 實例都在一個隔離的 Docker 容器中運行，Job 執行完畢後容器即銷毀（或被停用）。 |
| **權限管理：** 避免將高權限 PAT 寫入配置檔案。 | **環境變數傳遞：** 透過環境變數 (`-e PAT=...`) 將長期 PAT 傳入容器，用於 API 呼叫。 |

## 🚀 最小可行步驟 (Minimum Viable Step, MVS)

要讓容器化的 Runner 成功執行第一個 Job，需要完成以下步驟：

### Step 1: 建立長期 PAT 憑證

在 GitHub 上建立一個具備 **`workflow`** 權限 (或組織層級的 `admin:org`) 的 Personal Access Token (PAT)，作為呼叫 Runner 註冊 API 的憑證。

### Step 2: 撰寫 Dockerfile

定義 Runner 容器的環境。

```dockerfile
# 選擇一個基礎映像檔
FROM ubuntu:latest

# 安裝基本工具和 Runner 依賴 (例如 git, curl, jq)
RUN apt-get update && \
    apt-get install -y curl git jq && \
    rm -rf /var/lib/apt/lists/*

# 下載 GitHub Runner 軟體
RUN mkdir /actions-runner && cd /actions-runner && \
    curl -o actions-runner-linux-x64-*.tar.gz -L "[https://github.com/actions/runner/releases/download/v2.316.0/actions-runner-linux-x64-2.316.0.tar.gz](https://github.com/actions/runner/releases/download/v2.316.0/actions-runner-linux-x64-2.316.0.tar.gz)" && \
    tar xzf ./actions-runner-linux-x64-*.tar.gz

# 複製啟動腳本
COPY start.sh /actions-runner/
WORKDIR /actions-runner

# 設定容器啟動時執行的 Entrypoint
ENTRYPOINT ["/actions-runner/start.sh"]