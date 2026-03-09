# Stand By Me

Claude Code のエージェント機能を使って、GitHub issue を自動処理するシステムです。

## 概要

`repositories.yaml` に監視対象リポジトリを定義すると、Claude Code が定期的にissueをチェックし、分析・実装・PRの作成まで自動で行います。

## セットアップ

### 前提条件

- [Claude Code](https://claude.ai/code) がインストール済み
- [GitHub CLI (`gh`)](https://cli.github.com/) がインストール済みかつ認証済み

```bash
gh auth login
```

### リポジトリの設定

`repositories.yaml` を編集して監視対象リポジトリを追加します。

```yaml
repositories:
  - owner: your-org
    repo: your-repo
    labels:
      - claude       # このラベルがついたissueを処理対象にする
    priority: high   # high | normal | low
```

issueを処理対象にするには、対象issueに `labels` で指定したラベルをGitHub上で付与してください。

## 使い方

このプロジェクトのディレクトリで Claude Code を起動します。

```bash
cd stand-by-me
claude
```

### issueの確認

```bash
/check-issues
```

`repositories.yaml` に定義された全リポジトリの対象issueを一覧表示します。

### 定期監視

```bash
/loop 5m /check-issues
```

5分ごとに自動でissueをチェックします。

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
