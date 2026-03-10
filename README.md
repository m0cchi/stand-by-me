# Stand By Me

Claude Code のエージェント機能を使って、GitHub issue を自動処理するシステムである。

## 概要

`repositories.yaml` に監視対象リポジトリを定義すると、Claude Code が定期的にissueをチェックし、分析・実装・PRの作成まで自動で行う。

## セットアップ

### 前提条件

- [Claude Code](https://claude.ai/code) がインストール済み
- [GitHub CLI (`gh`)](https://cli.github.com/) がインストール済みかつ認証済み

```bash
gh auth login
```

### リポジトリの設定

`repositories.yaml` を編集して監視対象リポジトリを追加する。

```yaml
repositories:
  - owner: your-org
    repo: your-repo
    labels:
      - claude              # このラベルがついたissueを処理対象にする
    priority: high          # high | normal | low
    allowed_authors:        # 処理を許可するissue作成者（省略時は全員を対象）
      - trusted-user
```

issueを処理対象にするには、対象issueに `labels` で指定したラベルをGitHub上で付与する。

`allowed_authors` を設定すると、指定したユーザーが作成したissueのみを自動処理する。**プロンプトインジェクション攻撃を防ぐため、`allowed_authors` の設定を強く推奨する。**

## セキュリティ

このシステムはGitHub issueの内容をAIエージェントに渡して自動実行する。悪意のある第三者がissueにプロンプトインジェクション攻撃を仕込む可能性がある。

### 推奨される対策

- **`allowed_authors` を設定する**: 信頼できるユーザーが作成したissueのみを処理対象にする
- **`labels` フィルターを活用する**: 特定のラベルが付いたissueのみを処理する（ラベルはリポジトリ管理者のみが付与できる設定にする）
- **処理内容を定期的に確認する**: エージェントが実行した内容をレビューする

### `allowed_authors` の設定例

```yaml
repositories:
  - owner: your-org
    repo: your-repo
    labels:
      - claude
    priority: normal
    allowed_authors:
      - your-username     # 自分のアカウントのみを許可
      - trusted-teammate  # 信頼できるチームメンバーを追加
```

`allowed_authors` を省略した場合は全ユーザーのissueが処理対象になる。パブリックリポジトリで使用する場合は必ず設定する。

## 使い方

このプロジェクトのディレクトリで Claude Code を起動する。

```bash
cd stand-by-me
claude
```

### issueの確認

```bash
/check-issues
```

`repositories.yaml` に定義された全リポジトリの対象issueを一覧表示する。

### 定期監視

```bash
/loop 5m /check-issues
```

5分ごとに自動でissueをチェックする。

### issueの処理

```
Use issue-analyzer to analyze m0cchi/emacsenv#42, then use issue-implementer to fix it
```

## ファイル構成

```
stand-by-me/
├── repositories.yaml              # 監視対象リポジトリ定義
├── example_repositories.yaml      # 設定例
├── CLAUDE.md                      # エージェントへのルール定義
└── .claude/
    ├── agents/
    │   ├── issue-fetcher/         # YAMLを読んでissue一覧を取得
    │   ├── issue-analyzer/        # 個別issueを分析・計画作成
    │   └── issue-implementer/     # 実装してPRを作成
    └── skills/
        └── check-issues/          # issue確認のエントリポイント
```

## エージェントの役割

| エージェント | 役割 |
|---|---|
| `issue-fetcher` | `repositories.yaml` を読み込み、全リポジトリのissueを取得 |
| `issue-analyzer` | 指定issueを分析し、実装計画を作成 |
| `issue-implementer` | 分析結果をもとにコードを変更し、PRを作成 |
