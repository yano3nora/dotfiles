# project

## Overview

新規 project にコピーして使う汎用テンプレート置き場。

`dots project [dir]` がこのディレクトリのテンプレートを対象 project にコピーする。
`_README.md` は対象 project の `README.md` として使うテンプレート。
コピー時に先頭タイトルだけ対象ディレクトリ名へ差し替える。

## Files

- `mise.toml` - project-local mise 設定の雛形
- `.editorconfig` - editor 間の空白・改行ルール統一
- `.gitignore` - OS / editor / runtime / build output の基本除外
- `.gitattributes` - 改行・diff・binary 判定の基本設定
- `.npmrc` - npm の安全寄りデフォルト
- `_README.md` - project README の雛形
- `AGENTS.md` - agent 向け開発ガイド雛形
- `CLAUDE.md` - Claude Code 向け補足雛形
- `docs/` - ADR / SPEC / TASK の雛形

## Usage

```sh
dots project /path/to/project
```

## Policy

既存ファイルは上書きしない。
コピー後、TODO は project 固有の内容に必ず書き換える。
