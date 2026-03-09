#!/bin/bash
# verify_allowed_authors.sh
# allowed_authors の動作を検証するスクリプト
#
# このスクリプトは以下を検証する:
# 1. gh api user -q ".login" で現在のユーザーが取得できること
# 2. gh issue list --author オプションでフィルタリングが機能すること
# 3. repositories.yaml の allowed_authors 設定に応じた動作

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPOSITORIES_YAML="$SCRIPT_DIR/repositories.yaml"

echo "=== allowed_authors 検証スクリプト ==="
echo ""

# Step 1: 現在のGitHubユーザーを取得
echo "[Step 1] 現在のGitHubユーザーを取得"
if ! CURRENT_USER=$(gh api user -q ".login" 2>&1); then
  echo "  [FAIL] gh api user の実行に失敗しました: $CURRENT_USER"
  echo "  gh auth login を実行して認証してください。"
  exit 1
fi
echo "  [OK] 現在のユーザー: $CURRENT_USER"
echo ""

# Step 2: repositories.yaml の読み込み確認
echo "[Step 2] repositories.yaml の確認"
if [ ! -f "$REPOSITORIES_YAML" ]; then
  echo "  [FAIL] repositories.yaml が見つかりません: $REPOSITORIES_YAML"
  exit 1
fi
echo "  [OK] repositories.yaml が存在します"
echo ""

# Step 3: gh issue list --author オプションの動作確認
echo "[Step 3] gh issue list --author オプションの動作確認"
# repositories.yaml から最初のリポジトリを取得してテスト
FIRST_REPO=$(python3 -c "
import yaml, sys
with open('$REPOSITORIES_YAML') as f:
    data = yaml.safe_load(f)
repos = data.get('repositories', [])
if repos:
    r = repos[0]
    print(f\"{r['owner']}/{r['repo']}\")
" 2>/dev/null)

if [ -z "$FIRST_REPO" ]; then
  echo "  [SKIP] repositories.yaml にリポジトリが定義されていません"
else
  echo "  テスト対象リポジトリ: $FIRST_REPO"
  if gh issue list --repo "$FIRST_REPO" --state open --author "$CURRENT_USER" --json number,title,author --limit 5 &>/dev/null; then
    echo "  [OK] --author オプションが正常に動作しています"
  else
    echo "  [FAIL] --author オプションの実行に失敗しました"
    exit 1
  fi
fi
echo ""

# Step 4: allowed_authors 設定の確認
echo "[Step 4] repositories.yaml の allowed_authors 設定確認"
python3 -c "
import yaml, sys

with open('$REPOSITORIES_YAML') as f:
    data = yaml.safe_load(f)

current_user = '$CURRENT_USER'
repos = data.get('repositories', [])

for repo in repos:
    owner = repo['owner']
    name = repo['repo']
    allowed_authors = repo.get('allowed_authors')

    if allowed_authors is None:
        effective_authors = [current_user]
        source = 'gh api user (自動取得)'
    else:
        effective_authors = allowed_authors
        source = 'repositories.yaml'

    print(f'  {owner}/{name}:')
    print(f'    有効な allowed_authors: {effective_authors} (出典: {source})')
    if len(effective_authors) == 1:
        print(f'    gh コマンド: --author {effective_authors[0]} を使用')
    else:
        print(f'    gh コマンド: 各ユーザーごとに --author を使って複数回実行')
    print()
"
echo ""

echo "=== 検証完了 ==="
echo ""
echo "issue-fetcher エージェントは以下のルールで動作します:"
echo "  1. allowed_authors が未設定 → gh api user -q '.login' で取得したユーザーを使用"
echo "  2. allowed_authors が1名 → gh issue list --author <username> で直接フィルタリング"
echo "  3. allowed_authors が複数 → 各ユーザーごとに gh issue list を実行してマージ"
