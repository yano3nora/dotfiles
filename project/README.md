# project

## Overview

新規 project にコピーして使う汎用テンプレート置き場。

`dots project [dir]` がこのディレクトリのテンプレートを対象 project にコピーする。
TypeScript project では `--typescript`、React project では `--typescript --react` を追加する。
`_README.md` は対象 project の `README.md` として使うテンプレート。
コピー時に先頭タイトルだけ対象ディレクトリ名へ差し替える。

## Files

- `mise.toml` - project-local mise 設定の雛形
- `.editorconfig` - editor 間の空白・改行ルール統一
- `.gitignore` - OS / editor / runtime / build output の基本除外
- `.gitattributes` - 改行・diff・binary 判定の基本設定
- `_README.md` - project README の雛形
- `AGENTS.md` - agent 向け開発ガイド雛形
- `CLAUDE.md` - Claude Code 向け補足雛形
- `docs/` - ADR / SPEC / TASK の雛形
- `typescript/` - TypeScript project 向けの VS Code / oxc / Vitest / npm 雛形
- `typescript-react/` - React project 向けの oxlint 雛形

## Usage

```sh
dots project /path/to/project
dots project --typescript /path/to/typescript-project
dots project --typescript --react /path/to/react-project
```

`--typescript` は以下を追加する。

- `.vscode/settings.json`
- `.vscode/extensions.json`
- `.oxfmtrc.json`
- `.oxlintrc.json`
- `vitest.config.ts`
- `.npmrc`
- `package.json`

`--react` は `--typescript` と併用し、React plugin / rules を含む `.oxlintrc.json` を選ぶ。

`tsconfig.json` や framework 設定は追加しない。
Next.js / Vite / library で正解が割れるため、project 側で明示的に作る。

`--typescript` 利用後の TODO:

- `tsc --init` や Vite / Next.js など、project 固有の初期化に続く
- `package.json` の依存・バージョンの最適化は手動で行う

## Policy

既存ファイルは上書きしない。
コピー後、TODO は project 固有の内容に必ず書き換える。
