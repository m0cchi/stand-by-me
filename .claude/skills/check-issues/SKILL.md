---
name: check-issues
description: Check all repositories defined in repositories.yaml for open issues and display a summary
---

`repositories.yaml` に定義された全リポジトリのissueを確認してサマリーを表示する。

Use the issue-fetcher agent to read repositories.yaml and fetch all open issues from every repository listed there.

`allowed_authors` が設定されているリポジトリでは、許可された作成者のissueのみが返される。`allowed_authors` が未設定の場合は `gh api user -q ".login"` で取得した現在のユーザーのissueのみが返される。

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

## チーム自動起動

新規タスクが1件以上登録された場合、または既存のpendingタスクがある場合、以下の手順で自動処理を開始する:

1. `TeamCreate` でチームを作成する（description: "issue自動処理チーム"）
2. pendingタスクごとに `Agent` ツールで issue-implementer を起動する
   - `team_name`: 作成したチーム名
   - `name`: `implementer-<N>`（N は連番）
   - `run_in_background`: true
   - prompt にはタスクの詳細（owner, repo, issue_number, ブランチ名, コミットメッセージ）を含める
   - promptには「TaskUpdate でタスク #N の status を in_progress・owner を implementer-N に設定してから作業開始すること」を明記する
   - promptには「完了後は TaskUpdate でタスク status を completed に更新し、SendMessage で team-lead に完了報告すること」を明記する
3. チームが起動したことをユーザーに報告する
4. 全 implementer から完了報告を受け取ったら `SendMessage(type: "shutdown_request")` で全員をシャットダウンし、`TeamDelete` でチームを削除する
