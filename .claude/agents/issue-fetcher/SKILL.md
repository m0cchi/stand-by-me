---
name: issue-fetcher
description: Read repositories.yaml and fetch open issues from all defined repositories. Use this to get a list of issues that need processing.
tools: Read, Bash
model: haiku
---

`repositories.yaml` を読み込み、全リポジトリのissueを取得して一覧を返す。

## Steps

1. `repositories.yaml` を読み込む（プロジェクトルートにある）
2. `priority` 順（high → normal → low）にリポジトリをソート
3. 各リポジトリに対して以下を実行：
   ```bash
   gh issue list \
     --repo <owner>/<repo> \
     --state open \
     --label <label> \
     --json number,title,author,updatedAt \
     --limit 20
   ```
   ※ `labels` に複数ある場合は最初のラベルを使う（gh CLIは複数ラベルのOR指定不可のため1つずつ実行して重複を除く）

4. 結果を以下のフォーマットで出力する：

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
