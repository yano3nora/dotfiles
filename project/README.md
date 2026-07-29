# project

## Overview

新規 project にコピーして使う汎用テンプレート置き場。

`dots project [dir]` がこのディレクトリのテンプレートを対象 project にコピーする。
TypeScript (Node) project では `--typescript`、React project では `--typescript --react`、
Deno CLI project では `--deno` を追加する (`--typescript` とは排他)。
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
- `docs/` - ADR / SPEC / TASK の雛形と BACKLOG (未解決タスクの一元管理)
- `typescript/` - TypeScript project 向けの VS Code / oxc / Vitest / npm 雛形
- `typescript-react/` - React project 向けの oxlint 雛形
- `deno/` - Deno CLI project 向けの deno.json / VS Code / goreleaser release 雛形

## Usage

```sh
dots project /path/to/project
dots project --typescript /path/to/typescript-project
dots project --typescript --react /path/to/react-project
dots project --deno /path/to/deno-cli-project
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

`--deno` は以下を追加する。`__PROJECT_NAME__` placeholder は対象ディレクトリ名 (正規化済み) へ差し替わる。

- `.vscode/settings.json` / `.vscode/extensions.json` (denoland.vscode-deno)
- `deno.json` - tasks (test / fix / compile)、fmt (no-semi / single-quote / 80)、lint
- `.goreleaser.yaml` - deno builder による binary 配布雛形。対応しない target は削る
- `scripts/release.ts` - version bump・検証・publish 人間ゲート。`src/main.ts` に `export const VERSION = '<name> <x.y.z>'` が必要 (version は 3 要素の数値のみ対応)
- `mise.toml` - 共通雛形の代わりに deno + goreleaser + release tasks 入りの deno 版を使う

`--typescript` 利用後の TODO:

- `tsc --init` や Vite / Next.js など、project 固有の初期化に続く
- `package.json` の依存・バージョンの最適化は手動で行う

`--deno` 利用後の TODO:

- binary 配布しない project は `.goreleaser.yaml` / `scripts/release.ts` と mise.toml の release tasks を削る
- deno.json の compile task の permission flags を project の要件に合わせ、`.goreleaser.yaml` の flags と同期させる

## Policy

既存ファイルは上書きしない。
コピー後、TODO は project 固有の内容に必ず書き換える。
