# ai

## Overview

Agentic Coding 用ドキュメントのテンプレート置き場。

このディレクトリは、他 repo にコピーしてから、その repo の文脈に合わせて書き換える前提。
具体プロジェクトの文脈をテンプレートに直接入れない。

## Getting Started

```sh
cp ai/AGENTS.md /path/to/project/AGENTS.md
cp ai/CLAUDE.md /path/to/project/CLAUDE.md
mkdir -p /path/to/project/docs
cp ai/docs/*.md /path/to/project/docs/
```

コピー後、空欄や TODO を埋める。

## Files

- `AGENTS.md` - agent 向け開発ガイド
- `CLAUDE.md` - Claude Code 向け補足
- `docs/ADR-0000-template.md` - 技術判断記録
- `docs/SPEC-0000-template.md` - 仕様メモ
- `docs/TASK-YYMMDD-template.md` - 作業メモ

## My Recommendation

まず `AGENTS.md` だけでも書く。
ただし、他 repo の文脈を残したまま使い回さない。
