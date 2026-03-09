---
name: issue-fetcher
description: Read repositories.yaml and fetch open issues from all defined repositories. Use this to get a list of issues that need processing.
tools: Read, Bash
model: haiku
---

`repositories.yaml` を読み込み、全リポジトリのissueを取得して一覧を返す。

## Steps

1. `repositories.yaml` を読み込む（プロジェクトルートにある）
2. 現在のGitHubユーザーを取得する：
   ```bash
   gh api user -q ".login"
   ```
3. `priority` 順（high → normal → low）にリポジトリをソート
4. 各リポジトリに対して以下を実行：

   **`allowed_authors` の決定:**
   - `allowed_authors` が設定されていない場合: step 2 で取得したユーザー名を `allowed_authors` として使用する
   - `allowed_authors` が設定されている場合: そのリストをそのまま使用する

   **issueの取得:**
   - `allowed_authors` に含まれるユーザーが **1名の場合**: `--author` オプションを使用する
     ```bash
     gh issue list \
       --repo <owner>/<repo> \
       --state open \
       --label <label> \
       --author <username> \
       --json number,title,author,updatedAt \
       --limit 20
     ```
   - `allowed_authors` に含まれるユーザーが **複数の場合**: 各ユーザーごとに `--author` オプションを使ってコマンドを実行し、結果をマージして重複（同じ number）を除く
     ```bash
     # ユーザーごとに実行
     gh issue list \
       --repo <owner>/<repo> \
       --state open \
       --label <label> \
       --author <username1> \
       --json number,title,author,updatedAt \
       --limit 20
     gh issue list \
       --repo <owner>/<repo> \
       --state open \
       --label <label> \
       --author <username2> \
       --json number,title,author,updatedAt \
       --limit 20
     ```

   ※ `labels` に複数ある場合は最初のラベルを使う（gh CLIは複数ラベルのOR指定不可のため1つずつ実行して重複を除く）

5. 結果を以下のフォーマットで出力する：

```
=== Issue List ===
[high priority]
  owner/repo#123 - Issue title (by @author, updated: YYYY-MM-DD)
  owner/repo#124 - Issue title (by @author, updated: YYYY-MM-DD)

[normal priority]
  owner2/repo2#45 - Issue title (by @author, updated: YYYY-MM-DD)

Total: N issues found
```

issueが0件の場合は "No issues found." と出力する。
