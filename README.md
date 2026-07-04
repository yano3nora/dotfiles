# dotfiles
> https://github.com/topics/dotfiles

macOS 用の個人 dotfiles。

## Overview
この repo では以下を管理する。

- `zsh/` - zsh 設定
- `bin/` - 個人用コマンド
- `vscode/` - VSCode 設定
- `ghostty/` - Ghostty 設定
- `lazygit/` - LazyGit 設定
- `mise/` - global mise 設定
- `ai/` - Agentic Coding 用テンプレート

この dotfiles は `mise` が入っている前提。
global CLI tool は `mise/config.toml` で管理し、project local な version は各 project の `mise.toml` に任せる。

## Getting Started
```sh
git clone xxx
cd dotfiles
./bin/dotfiles link
mise install
dotfiles doctor
exec $SHELL -l
```

`dotfiles link` は既存ファイルを `.bak.YYYYMMDDHHMMSS` に退避してから symlink を作る。

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
基本は `mise` で global CLI tool を管理する。
ただし、PHP や macOS コマンド差し替え系のようにビルドや OS 依存が重いものは Homebrew 管理のままにする。

## Workflows
### zsh 設定を変える
`zsh/zshrc.d/*.zsh` を編集して、反映する。

```sh
reload
```

### 個人用コマンドを追加する
```sh
dotfiles addbin my-command
# bin/my-command を編集する
dotfiles link
```

手で `bin/` に追加した場合は `chmod +x bin/<name>` を忘れない。

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
