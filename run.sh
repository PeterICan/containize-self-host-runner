# 建構映像檔
docker build -t my-custom-runner:latest .

# 運行容器 (替換為您的實際值)
docker run -d \
    -e REPO_URL="[https://github.com/YourOrg/YourRepo](https://github.com/YourOrg/YourRepo)" \
    -e RUNNER_PAT="ghp_xxxxxxxxxxxxxxxxxxxxxxxxxx" \
    -e RUNNER_NAME="docker-$(uuidgen)" \
    --name my-runner-instance \
    my-custom-runner:latest