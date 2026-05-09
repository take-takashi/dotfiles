---
name: commit-conventional-ja
description: >-
  Conventional Commits 1.0.0形式で日本語コミットを作成する。ユーザーが「コミットして」「Conventional Commitでまとめて」「差分を良い感じでコミット」などを依頼したときに使う。件名は type(scope): subject を守り、本文は日本語の「変更内容」「背景」ブロックで記載する。
---

# Commit Conventional JA

以下の手順で実行する。

1. 変更状態を確認する。
   - `git status --short`
   - `git diff --name-only`
2. 差分を確認し、Conventional Commits の `type` と必要なら `scope` を決める。
   - 例: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`
3. 日本語コミットメッセージを作る。
   - 1行目: `<type>(<scope>): <要約>` または `<type>: <要約>`
   - 本文: 次の2ブロックを使う。

```text
変更内容:
- ...
- ...

背景:
- ...
```

4. `git add` と `git commit` を実行する。
   - 原則として `git commit -m "件名" -m "本文全体"` を使い、一時ファイルは避ける。
   - 本文は 1 つの `-m` にまとめ、`変更内容:` と `背景:` のブロックをその中で改行して記載する。
5. コミット結果を確認する。
   - `git show --no-patch --pretty=fuller HEAD`

## Rules

- 日本語で書く。
- Conventional Commits 1.0.0 形式を厳守する。
- 変更ファイルと本文の箇条書きを一致させる。
- 破壊的変更がある場合のみ `!` と `BREAKING CHANGE:` を使う。
- ユーザーから type/scope 指定があればそれを優先する。

## Output Style

- 最終報告では以下を簡潔に示す。
  - コミットハッシュ
  - コミット件名
  - 変更ファイル一覧
