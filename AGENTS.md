# AGENTS - Development Guide
> https://github.com/topics/dotfiles

## Overview
- この repo は macOS 用の個人 dotfiles を管理する。
- 主な管理対象は `zsh/`, `bin/`, `mise/`, `vscode/`, `ghostty/`, `lazygit/`, `ai/`。
- `bin/dotfiles` が symlink 管理の入口。
- global CLI tool は原則 `mise/config.toml` で pin する。project local な tool version は各 project の `mise.toml` に任せる。
- Agentic Coding 用テンプレートは `ai/` に置く。他 repo の具体文脈を root docs に混ぜない。

### 🎯 Role & Objective
あなたはエキスパートソフトウェアエンジニアとして、既存環境を壊さず、設定管理・CLI 管理・Agentic Coding 用テンプレートを整理すること。

### 🚨 CRITICAL: Architecture
- **公開操作は禁止**: `github push` や `npm publish` など、外部へ公開・配布する操作は Agent が実行しない。人間が判断して実行する。
- **コミットは指示されたときだけ**: `git commit` なども基本的には人間判断で行うため、指示されたとき以外はコミットせず人間に判断を委ねること。
- **`dotfiles link` が唯一の適用入口**: 新しい管理対象ファイルを増やす場合は、repo に設定ファイルを置き、`bin/dotfiles` の `link_all` に symlink を追加する。
- **既存ファイルを黙って上書きしない**: `dotfiles link` は既存ファイルを `.bak.YYYYMMDDHHMMSS` に退避する設計を維持する。
- **曖昧なコマンドを増やさない**: `install` のように責務が広い名前は禁止。`link` / `doctor` / `addbin` のように役割を分ける。
- **global CLI tool は mise に寄せる**: `mise/config.toml` では explicit version を pin し、`latest` は使わない。
- **例外を無理に mise 化しない**: PHP や macOS コマンド差し替え系のようにビルドや OS 依存が重いものは Homebrew 管理を許容する。
- **root README は短い入口に保つ**: 詳細は各ディレクトリの `README.md` に逃がす。

### 📂 Code Organization Constraints
- **`bin/`**: 個人用コマンド。新規追加は `dotfiles addbin <name>` を使う。手作業で追加した場合は `chmod +x` を忘れない。
- **`zsh/`**: zsh 設定。`zsh/zshrc` が `zsh/zshrc.d/*.zsh` をファイル名順に読む。
- **`mise/`**: global mise config。`mise/config.toml` を `~/.config/mise/config.toml` に symlink する。
- **`vscode/`, `ghostty/`, `lazygit/`**: 各ツール設定。link 対象を増やす場合は `bin/dotfiles` を更新する。
- **`ai/`**: Agentic Coding 用テンプレート。`ai/AGENTS.md`, `ai/CLAUDE.md`, `ai/docs/*` を他 repo にコピーして書き換える前提。
- **root `AGENTS.md` / `CLAUDE.md`**: この dotfiles repo 自身の Agentic Coding docs。

### 🛠️ Workflow & Development Rules
- **Testing**: 変更内容に応じて以下を実行する。
    - `zsh -n bin/dotfiles`
    - `zsh -n zsh/zshrc`
    - `for f in zsh/zshrc.d/*.zsh; do zsh -n "$f" || break; done`
    - `dotfiles doctor`
- **Documentation**:
    - root `README.md` は短い入口にする。
    - 詳細は `bin/README.md`, `zsh/README.md`, `mise/README.md` などに書く。
    - Agentic Coding 用テンプレートを変えたら `ai/README.md` も確認する。
- **Safety**:
    - 実 HOME に影響する `dotfiles link`, `mise install`, `brew uninstall` は影響範囲を確認してから行う。
    - 一時 HOME で検証できる場合は先に `HOME=/private/tmp/... ./bin/dotfiles link` で確認する。
- **Versioning / Release**:
    - 個人 dotfiles なので release 運用はしない。変更単位が大きくなったら commit 前に `git diff --stat` と主要差分を確認する。

## Domains
- `link`
    - repo 内の管理対象ファイルを実 HOME 配下へ symlink する処理。既存ファイルは backup する。
- `doctor`
    - 必要コマンドの存在確認。mise 管理ツールは `mise which` で確認する。
- `addbin`
    - `bin/<name>` に executable なコマンド雛形を作る補助コマンド。
- `mise`
    - global CLI tool / runtime の version 管理。project local version は各 project に任せる。
- `zshrc.d`
    - zsh 設定の分割単位。`00-initial`, `10-tool`, `20-zsh`, `30-alias`, `40-func-*` の順序を維持する。
- `ai templates`
    - 他 repo にコピーして書き換える Agentic Coding 用ドキュメントテンプレート。
