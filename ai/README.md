# ai

## Overview

AI coding agent 向けの個人用グローバル設定を管理する。

Managed files:

- `instructions.md` -> `~/.codex/instructions.md` (Codex)
- `CLAUDE.md` -> `~/.claude/CLAUDE.md` (Claude Code)

project 固有の `AGENTS.md` / `CLAUDE.md` は `project/` テンプレートの管轄で、ここでは扱わない。

## Getting Started

```sh
dots link
```

## Setup / Basic Usage

個人の口調・アドバイザーとしての姿勢・成果物出力ルールなど、ツール横断で効かせたい指示をここに書く。
Agent 固有の設定形式や機能差はそれぞれのファイルに閉じる。

## Trouble Shooting

反映されない場合は symlink を確認する:

```sh
readlink ~/.codex/instructions.md
readlink ~/.claude/CLAUDE.md
```

## My Recommendation

企業名・製品名・機密情報を書かないこと。個人のグローバル指示は公開 repo に載る前提で書く。
