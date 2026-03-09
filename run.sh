#!/bin/bash
# Stand By Me - GitHub Issue Processor

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# gh CLI 認証チェック
if ! gh auth status &> /dev/null; then
  echo "[ERROR] GitHub CLI が認証されていません。'gh auth login' を実行してください。"
  exit 1
fi

echo "[INFO] Stand By Me を起動します。"
echo "[INFO] 起動後に以下のコマンドでissue監視を開始してください："
echo ""
echo "  /loop 5m /check-issues"
echo ""

claude --dangerously-skip-permissions
