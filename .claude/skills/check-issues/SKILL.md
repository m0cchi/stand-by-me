---
name: check-issues
description: Check all repositories defined in repositories.yaml for open issues and display a summary
---

`repositories.yaml` に定義された全リポジトリのissueを確認してサマリーを表示する。

Use the issue-fetcher agent to read repositories.yaml and fetch all open issues from every repository listed there.

`allowed_authors` が設定されているリポジトリでは、許可された作成者のissueのみが返される。

Display the results clearly so the user can decide which issues to process next.

## タスクリストへの登録

issueをサマリーとして表示した後、以下の手順でタスクリストへ登録する:

1. `TaskList` を呼び出して既存タスクを確認する
2. まだタスク化されていないissueのみを対象にする（subject に `<owner>/<repo>#<number>` が含まれるものは重複とみなす）
3. 対象issueごとに `TaskCreate` でタスクを作成する
   - **subject**: `<owner>/<repo>#<number>: <title>`
   - **description**: issueのbodyと対応手順（ブランチ名・コミットメッセージ・PR作成先）を含める
   - **activeForm**: `<repo>#<number> を実装中`
   - **metadata**: `{"owner": "<owner>", "repo": "<repo>", "issue_number": <number>, "priority": "<priority>", "labels": [...]}`
4. 登録結果（新規追加・スキップ）をユーザーに報告する
