# ai

## Overview

AI coding agent 向けの個人用グローバル設定を管理する。

Managed files:

- `CLAUDE.md` -> `~/.claude/CLAUDE.md` (Claude Code) / `~/.codex/AGENTS.md` (Codex)
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
model = "gpt-6-astra"
model_reasoning_effort = "medium"
sandbox_mode = "workspace-write"
approval_policy = "on-request"
approvals_reviewer = "auto_review"
personality = "pragmatic"
```

## Claude Code Plugins

導入済み plugin の記録。settings 自体 (`~/.claude/settings.json`) は機微情報が乗りやすいため symlink 管理せず、ここに導入手順と使い方を残して別環境で再現する。

### chrome-devtools-mcp (試用中)

Chrome を DevTools protocol 経由で Claude Code から操作・デバッグする MCP server + skills (a11y-debugging, memory-leak-debugging, debug-optimize-lcp など)。ブラウザ実機での動作確認・性能調査を Agent に任せられるのが嬉しさ。

構成: **plugin は使わない**。MCP server は user scope、CLI は `bin/chrome-devtools`、skills は local clone からの symlink で入れる。

- MCP server も CLI も `mise exec node@24 npm:chrome-devtools-mcp@latest --` で起動し、Node を project に委ねない。理由: plugin 内蔵の server 定義 (`npx chrome-devtools-mcp`) と mise の npm shim は PATH の node で動くため、`.node-version` が 18 以下の project では SyntaxError で即死する (1.9.0 は Node 20.19+ 必須)。plugin は server 定義を差し替えられない ([#1232](https://github.com/ChromeDevTools/chrome-devtools-mcp/issues/1232)) ので plugin ごとやめた
- `npm:chrome-devtools-mcp` は mise の global config に載せない。載せると shim が PATH の先頭に出て `bin/chrome-devtools` を隠す。初回は `mise exec` が自動 install する。更新は自動ではない
- skills は upstream の clone (`~/git/ChromeDevTools/chrome-devtools-mcp/skills/*`) を `dots link` で `~/.claude/skills` に張る。clone 側の skill 増減に追従する。`chrome-devtools-cli` skill が叩く `chrome-devtools` は `bin/chrome-devtools` に解決される
- clone は `--depth 1` で submodule なし (~16MB)。upstream が `devtools-frontend` を submodule 化しており (数GB)、marketplace 経由の clone は timeout する ([#2563](https://github.com/ChromeDevTools/chrome-devtools-mcp/issues/2563))

```sh
git clone --depth 1 https://github.com/ChromeDevTools/chrome-devtools-mcp.git ~/git/ChromeDevTools/chrome-devtools-mcp
dots link
claude mcp add --scope user chrome-devtools -- mise exec node@24 npm:chrome-devtools-mcp@latest -- chrome-devtools-mcp
```

- 更新: `mise install npm:chrome-devtools-mcp@latest && git -C ~/git/ChromeDevTools/chrome-devtools-mcp pull && dots link` (server / CLI / skills の 3 つ)
- 旧構成 (plugin + mise global) からの移行: `claude plugin disable chrome-devtools-mcp@chrome-devtools-plugins` してから上記を実行する。marketplace `chrome-devtools-plugins` は不要になるので remove してよい
- リスク: MCP server は接続中の Chrome の cookie・ログイン済みセッション・ページ内容へアクセスできる。下記 autoConnect で実ブラウザへ繋ぐ場合はこれを許容していることを自覚して使う
- `dots mcp on/off` の対象外。理由: あれは会社リソースへの経路 (http) を一括で開閉する仕組みで、この server はローカル完結

運用方針: user scope の server は autoConnect なし = 毎回独立した Chrome インスタンスを起動する構成にし、実ブラウザ接続 (autoConnect) は project 単位で opt-in する。ログイン済み実ブラウザへの接続を全 project へ開放しないための opt-in でもある。

autoConnect の設定手順 (Chrome 144+ が必要):

1. Chrome で `chrome://inspect/#remote-debugging` を開き、リモートデバッグを有効にする
2. project 直下の `.mcp.json` に `--autoConnect` 付きで server を定義する (Node の固定も同様に必要)

```json
{
  "mcpServers": {
    "chrome-devtools": {
      "command": "mise",
      "args": ["exec", "node@24", "npm:chrome-devtools-mcp@latest", "--", "chrome-devtools-mcp", "--autoConnect"]
    }
  }
}
```

この repo では user scope の server (autoConnect なし) と同名の二重定義になる (`/mcp` で確認できる)。project scope が優先されるので実害はない。

## MCP Servers / claude.ai Connectors (`dots mcp`)

Slack / Notion / Google Drive (claude.ai connectors) や Figma (remote MCP) など会社リソースへ届く経路は、普段は全部 off にしておき、調査フェーズだけ一括で on にする。理由は 2 つ:

- セキュリティ: 開発中に外部リソースへ届く経路を常設しない
- `@` 補完はファイル名の列挙に限定したい。常設すると remote リソースが同じ補完に並んでノイズになる

```sh
dots mcp        # 状態表示
dots mcp on     # claude.ai connectors を有効化 + ai/mcp.json の server を claude (user scope) / codex (global) に登録
dots mcp off    # 全部 off
```

- 定義は `mcp.json` (Claude の `.mcp.json` 形式、http のみ)。増やしたいときはここに足す
- connectors は `~/.claude/settings.json` の `disableClaudeAiConnectors` で一括 off (個別制御はできない)
- **off は Claude Code のセッションを全部閉じてから実行すること**。起動中のセッションが `~/.claude.json` へ自身の設定状態を書き戻すため、起動したまま remove しても即復活する。on / off どちらも反映には Claude Code の再起動が要る
- OAuth: codex は `codex mcp add` の時点でブラウザが開く。claude はセッション内の `/mcp` か `claude mcp login <name>` で行う
- chrome-devtools plugin はローカル開発用なので対象外

## Trouble Shooting

反映されない場合は symlink を確認する:

```sh
readlink ~/.codex/AGENTS.md
readlink ~/.claude/CLAUDE.md
```

## My Recommendation

企業名・製品名・機密情報を書かないこと。個人のグローバル指示は公開 repo に載る前提で書く。
