# Stand By Me - GitHub Issue Processor

## Overview

このプロジェクトは `repositories.yaml` に定義されたGitHubリポジトリのissueを自動処理するシステムです。

## Repository Configuration

監視対象リポジトリは `repositories.yaml` で管理されます。

```yaml
repositories:
  - owner: <org or user>
    repo: <repository name>
    labels:
      - <label to filter>
    priority: high | normal | low
    allowed_authors:        # オプション: 許可する作成者のリスト
      - <github username>   # 省略した場合は gh api user の結果（現在のユーザー）を対象にする
```

issueを取得する際は必ずこのファイルを読み込み、全リポジトリを対象にしてください。

`allowed_authors` が設定されている場合、そのリストに含まれる作成者のissueのみを自動処理の対象にします。

## Workflow

1. `repositories.yaml` を読み込んでリポジトリ一覧を取得
2. 各リポジトリのissueを `priority` 順（high → normal → low）に取得
3. `labels` に一致するissueのみを対象にする
4. `allowed_authors` が設定されている場合、その作成者のissueのみを対象にする。未設定の場合は `gh api user -q ".login"` で取得した現在のユーザーを対象にする
5. TaskCreate でタスクを登録し、status を `in_progress` に設定する
6. issue-analyzer エージェントで分析
7. issue-implementer エージェントで実装
8. issue-reviewer エージェントでコードレビューを行う
   - レビューで問題が見つかった場合は issue-implementer エージェントに差し戻して再修正させる
   - 差し戻しと再修正は最大3回まで繰り返す
   - 3回を超えても承認されない場合はスキップとして処理する
9. レビュー承認後、TaskUpdate でタスクの status を `completed` に更新する
10. 失敗・スキップした場合は TaskUpdate で status を `failed` に更新する

## Review Process

issue-reviewer エージェントは以下の観点でコードレビューを行う：

- issue の要件を満たしているか
- セキュリティ上の問題がないか（OWASP Top 10 等）
- 既存のコードスタイルに合っているか
- 不必要な変更が含まれていないか（over-engineering、無関係なリファクタリング等）
- テストが適切に追加されているか（必要な場合）

レビュー結果は以下のいずれかを返す：
- `APPROVED`: 問題なし、PRを作成してよい
- `CHANGES_REQUESTED`: 修正が必要、具体的な修正内容を issue-implementer に伝えて差し戻す

## Repository Clone & Worktree

issueを実装する前に以下の手順でリポジトリを準備する：

1. ローカルにリポジトリが存在するか確認する（例: `~/dev/<owner>/<repo>`）
2. 存在しない場合は `gh repo clone <owner>/<repo> ~/dev/<owner>/<repo>` でcloneする
3. origin main を最新化する：
   ```bash
   cd ~/dev/<owner>/<repo>
   git fetch origin main
   git checkout main
   git merge --ff-only origin/main
   ```
4. git worktreeで作業ディレクトリを作成する：
   ```bash
   cd ~/dev/<owner>/<repo>
   git worktree add ~/dev/<owner>/<repo>-worktree/<branch-name> -b <branch-name>
   ```
5. issue-implementer は worktree のパス内で作業する

## PR作成前のConflict解消

PRを作成する前に、origin main との conflict を解消する：

```bash
cd ~/dev/<owner>/<repo>-worktree/<branch-name>
git fetch origin main
git rebase origin/main
# conflict が発生した場合は解消してから git rebase --continue
```

## GitHub CLI Commands

```bash
# リポジトリのissue取得
gh issue list --repo <owner>/<repo> --state open --label <label> --json number,title,body,labels,author

# issue詳細取得
gh issue view <number> --repo <owner>/<repo> --json number,title,body,labels,author,assignees

# ラベル追加
gh issue edit <number> --repo <owner>/<repo> --add-label "in-progress"

# コメント追加
gh issue comment <number> --repo <owner>/<repo> --body "message"
```

## Rules

- issueを処理する前に必ず `repositories.yaml` を参照すること
- `priority: high` のリポジトリを優先して処理する
- 作業ブランチ名: `issue-<owner>-<repo>-<number>-<short-description>`
- コミットメッセージ: `Fix <owner>/<repo>#<number>: <description>`
- PRは必ず対象リポジトリに作成し、issueにリンクする
- 実装作業は必ず git worktree 内で行う（直接mainブランチで作業しない）
- clone先: `/tmp/stand-by-me/<owner>/<repo>`、worktree先: `/tmp/stand-by-me/<owner>/<repo>-worktree/<branch-name>`
