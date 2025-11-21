@echo off
REM 取得腳本所在目錄
set "SCRIPT_DIR=%~dp0"

REM 切換到專案根目錄
pushd "%SCRIPT_DIR%"
cd ..
set "PROJECT_ROOT=%CD%"
popd

cd "%PROJECT_ROOT%" || exit /b 1

echo -> 正在使用 Docker Compose 建置並啟動 Runner...

REM 使用 docker-compose 啟動
REM -p 指定專案名稱
REM -d 背景執行
REM --build 強制重新建置映像檔
docker-compose -p self_host-runner_test up -d --build

echo -> 容器已啟動，請使用 'docker-compose logs -f' 查看日誌。