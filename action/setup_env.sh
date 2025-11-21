#!/bin/bash

# 取得腳本所在目錄 (相容 source 執行模式)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PAT_FILE="$SCRIPT_DIR/../PAT.txt"

if [ -f "$PAT_FILE" ]; then
    # 讀取檔案內容並移除換行符號
    export PAT=$(cat "$PAT_FILE" | tr -d '[:space:]')
    echo "✅ PAT 已從 $PAT_FILE 讀取並匯出。"
else
    echo "❌ 錯誤: 找不到 $PAT_FILE"
    echo "請確認專案根目錄下是否有 PAT.txt 檔案。"
    # 注意: source 的腳本中使用 exit 會導致終端機關閉，建議使用 return
    return 1 2>/dev/null || exit 1
fi
