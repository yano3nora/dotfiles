# dotfiles
> https://github.com/topics/dotfiles

macOS 用の個人 dotfiles。

## Overview
この dotfiles は `mise` を利用する前提で以下を管理する。

- `zsh/` - zsh 設定
- `bin/` - 個人用コマンド
- `vscode/` - VSCode 設定
- `ghostty/` - Ghostty 設定
- `lazygit/` - LazyGit 設定
- `mise/` - global mise 設定
- `ai/` - Agentic Coding 用テンプレート

## Getting Started
```sh
git clone xxx
cd dotfiles

# setup symlinks with backup
./bin/dotfiles link

# setup tools
mise install
dotfiles doctor

# exec $SHELL -l
reload
```

## Commands
```sh
dotfiles link           # 管理対象の symlink を作る
dotfiles doctor         # 必要なコマンドを確認する
dotfiles addbin <name>  # bin/<name> を実行可能な雛形つきで作る
```

`dotfiles link` が作る主なリンク:

- `~/.config/dotfiles` -> this repository
- `~/.zshrc` -> `zsh/zshrc`
- `~/.config/mise/config.toml` -> `mise/config.toml`
- `~/.local/bin/*` -> `bin/*`
- VSCode / Ghostty / LazyGit 設定

## Tool Policy
- 基本は `mise` で global CLI tool を管理
- ただし、PHP や macOS コマンド差し替え系のようにビルドや OS 依存が重いものは Homebrew 管理のままに

## Workflows
### 個人用コマンドを追加する
```sh
# chmod +x しながら bin/my-command 作成
dotfiles addbin my-command

# bin/my-command を編集してから
dotfiles link
```

### 管理対象ファイルを増やす
1. repo に設定ファイルを置く
2. `bin/dotfiles` の `link_all` に symlink を追加する
3. `dotfiles link` を実行する

## Details
- [`bin/README.md`](bin/README.md)
- [`zsh/README.md`](zsh/README.md)
- [`vscode/README.md`](vscode/README.md)
- [`ghostty/README.md`](ghostty/README.md)
- [`lazygit/README.md`](lazygit/README.md)
- [`mise/README.md`](mise/README.md)
- [`ai/README.md`](ai/README.md)
