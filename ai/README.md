# ai

## Overview

AI coding agent 向けの個人用グローバル設定を管理する。

Managed files:

- `CLAUDE.md` -> `~/.claude/CLAUDE.md` (Claude Code) / `~/.codex/instructions.md` (Codex)
- `skills/*/` -> `~/.claude/skills/*` / `~/.codex/skills/*`

project 固有の `AGENTS.md` / `CLAUDE.md` は `project/` テンプレートの管轄で、ここでは扱わない。

## Getting Started

```sh
dots link
```

## Setup / Basic Usage

個人の口調・アドバイザーとしての姿勢・成果物出力ルールなど、ツール横断で効かせたい指示をここに書く。
Agent 固有の設定形式や機能差はそれぞれのファイルに閉じる。

## Codex CLI

`~/.codex/config.toml` は project path、trust、plugin 状態などを Codex 自身が書き戻すため、repo 管理しない。次の設定だけ手動で維持する:

```toml
model = "gpt-5.6-sol"
model_reasoning_effort = "high"
sandbox_mode = "workspace-write"
approval_policy = "on-request"
approvals_reviewer = "auto_review"
```

## Claude Code Plugins

導入済み plugin の記録。settings 自体 (`~/.claude/settings.json`) は機微情報が乗りやすいため symlink 管理せず、ここに導入手順と使い方を残して別環境で再現する。

### ponytail (試用中)

over-engineering 抑止の skill 集。YAGNI 徹底・標準ライブラリ優先・最小差分を強制することで、Agent が生成しがちな過剰な抽象化・不要な依存を削る。合わなければ削除する前提で試用中。

```sh
claude plugin marketplace add DietrichGebert/ponytail
claude plugin install ponytail@ponytail
```

代表的な使い方:

- `/ponytail [lite|full|ultra|off]` — 最小実装モードの強度切替。以降のコーディング作業全般に効く
- `/ponytail-review` — diff を over-engineering 観点のみでレビュー (正しさは見ない。/code-review と併用)
- `/ponytail-audit` — repo 全体の bloat 棚卸し。削除・簡素化候補のランク付きレポート
- `/ponytail-debt` — `ponytail:` コメントで残した意図的ショートカットの台帳化

### chrome-devtools-mcp (試用中)

Chrome を DevTools protocol 経由で Claude Code から操作・デバッグする MCP server + skills (a11y-debugging, memory-leak-debugging, debug-optimize-lcp など)。ブラウザ実機での動作確認・性能調査を Agent に任せられるのが嬉しさ。

**特殊な導入をしているので注意**: 2026-08 時点で upstream が `devtools-frontend` を git submodule 化した影響 (Chromium / LLVM を再帰的に引くため数GB) で、公式手順の `/plugin marketplace add ChromeDevTools/chrome-devtools-mcp` はデフォルトの 120s timeout 内に clone が終わらず失敗する。回避策として submodule なしの local clone (~16MB) を directory marketplace として登録している:

```sh
# 通常の git clone は submodule を取得しないため軽量で済む
git clone --depth 1 https://github.com/ChromeDevTools/chrome-devtools-mcp.git ~/git/ChromeDevTools/chrome-devtools-mcp
claude plugin marketplace add ~/git/ChromeDevTools/chrome-devtools-mcp
claude plugin install chrome-devtools-mcp@chrome-devtools-plugins
```

- 更新: `git -C ~/git/ChromeDevTools/chrome-devtools-mcp pull && claude plugin marketplace update chrome-devtools-plugins` (local 参照のため自動更新されない)
- 復旧: upstream の repo 軽量化 ([#2563](https://github.com/ChromeDevTools/chrome-devtools-mcp/issues/2563)) が済んだら、この marketplace を remove して公式手順に戻す
- リスク: MCP server は接続中の Chrome の cookie・ログイン済みセッション・ページ内容へアクセスできる。下記 autoConnect で実ブラウザへ繋ぐ場合はこれを許容していることを自覚して使う

運用方針: plugin は維持し、実ブラウザ接続 (autoConnect) は project 単位で opt-in する。

- plugin 内蔵の server 定義により、全 project で MCP server が使える。ただしこれは autoConnect なし = 毎回独立した Chrome インスタンスを起動する構成
- plugin 内蔵 server には起動フラグを注入できない ([#1232](https://github.com/ChromeDevTools/chrome-devtools-mcp/issues/1232) が open)。そのため autoConnect が必要な repo では、フラグ付きの server 定義を `.mcp.json` に自分で書く
- ログイン済み実ブラウザへの接続を全 project へ開放しないための opt-in でもある
- skills を使わないと判断したら、plugin を disable して user scope (`claude mcp add --scope user`) に一本化する
- `chrome-devtools-cli` skill は PATH 上の `chrome-devtools` コマンドを Bash から叩く前提。この CLI は mise (`npm:chrome-devtools-mcp`) で導入する。MCP server の経路 (npx) とは別物で、mise で入れても plugin / `.mcp.json` の server には影響しない

autoConnect の設定手順 (Chrome 144+ が必要):

1. Chrome で `chrome://inspect/#remote-debugging` を開き、リモートデバッグを有効にする
2. project 直下の `.mcp.json` に `--autoConnect` 付きで server を定義する

```json
{
  "mcpServers": {
    "chrome-devtools": {
      "command": "npx",
      "args": ["-y", "chrome-devtools-mcp@latest", "--autoConnect"]
    }
  }
}
```

この repo では plugin 内蔵の server (autoConnect なし) と同名の二重定義になる (`/mcp` で確認できる)。重複が邪魔なら `claude plugin disable chrome-devtools-mcp --scope local` で repo 単位で plugin を切れるが、その repo では skills も無効になる (MCP server だけを個別に切る手段はない)。

## Claude Code MCP Servers

### figma (使うときだけ on)

公式 Figma MCP server。常設すると `@` 補完に Figma リソースが並んで邪魔なので、普段は未登録にしておき、デザイン参照タスクのときだけ user scope に追加して終わったら削除する運用。

```sh
# on
claude mcp add --transport http figma https://mcp.figma.com/mcp -s user

# off
claude mcp remove figma -s user
```

- **off は Claude Code のセッションを全部閉じてから実行すること**。起動中のセッションが `~/.claude.json` へ自身の設定状態を書き戻すため、起動したまま remove しても即復活する
- 登録したまま project 単位で切りたい場合は `/mcp` からサーバを選んで disable もできる (CLI にはトグルコマンドなし)

## Trouble Shooting

反映されない場合は symlink を確認する:

```sh
readlink ~/.codex/instructions.md
readlink ~/.claude/CLAUDE.md
```

## My Recommendation

企業名・製品名・機密情報を書かないこと。個人のグローバル指示は公開 repo に載る前提で書く。
