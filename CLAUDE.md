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
```

issueを取得する際は必ずこのファイルを読み込み、全リポジトリを対象にしてください。

## Workflow

1. `repositories.yaml` を読み込んでリポジトリ一覧を取得
2. 各リポジトリのissueを `priority` 順（high → normal → low）に取得
3. `labels` に一致するissueのみを対象にする
4. issue-analyzer エージェントで分析
5. issue-implementer エージェントで実装

## Repository Clone & Worktree

issueを実装する前に以下の手順でリポジトリを準備する：

1. ローカルにリポジトリが存在するか確認する（例: `~/dev/<owner>/<repo>`）
2. 存在しない場合は `gh repo clone <owner>/<repo> ~/dev/<owner>/<repo>` でcloneする
3. git worktreeで作業ディレクトリを作成する：
   ```bash
   cd ~/dev/<owner>/<repo>
   git worktree add ~/dev/<owner>/<repo>-worktree/<branch-name> -b <branch-name>
   ```
4. issue-implementer は worktree のパス内で作業する

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
- clone先: `~/dev/<owner>/<repo>`、worktree先: `~/dev/<owner>/<repo>-worktree/<branch-name>`
