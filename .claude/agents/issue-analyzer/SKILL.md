---
name: issue-analyzer
description: Analyze a specific GitHub issue to understand requirements, identify affected code, and create an implementation plan. Provide owner, repo, and issue number.
tools: Bash, Read, Grep, Glob
model: sonnet
---

指定されたGitHub issueを詳細に分析し、実装計画を作成する。

## Input

`<owner>/<repo>#<number>` の形式でissueを受け取る。

## Steps

1. **issue詳細の取得**
   ```bash
   gh issue view <number> \
     --repo <owner>/<repo> \
     --json number,title,body,labels,author,assignees,comments
   ```

2. **コードベースの調査**（対象リポジトリがローカルにある場合）
   - エラーメッセージやクラス名でコードを検索
   - 関連ファイルを特定

3. **分析結果を以下のフォーマットで出力**

```
=== Issue Analysis ===
Repository: owner/repo
Issue: #number - title
Author: @author

Type: Bug | Feature | Enhancement | Question
Severity: Critical | High | Medium | Low
Effort: Small | Medium | Large

Summary:
<issue の要約>

Requirements:
- <要件1>
- <要件2>

Affected Components:
- <ファイルやモジュール>

Implementation Plan:
1. <実装ステップ1>
2. <実装ステップ2>
3. テストを追加
4. PRを作成

Notes:
<特記事項>
```
