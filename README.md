# dotfiles
> https://github.com/topics/dotfiles

macOS 用の個人 dotfiles。

## Overview
この dotfiles は `mise` を利用する前提で以下を管理する。

- `zsh/` - zsh 設定
- `bin/` - 個人用コマンド
- `git/` - Git global config
- `project/` - 新規 project 用の汎用テンプレート
- `vscode/` - VSCode 設定
- `ghostty/` - Ghostty 設定
- `lazygit/` - LazyGit 設定
- `mise/` - global mise 設定

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
dotfiles project [dir] # 新規 project 用テンプレートをコピーする
```

`dotfiles link` が作る主なリンク:

- `~/.config/dotfiles` -> this repository
- `~/.gitconfig` -> `git/gitconfig`
- `~/.gitignore_global` -> `git/gitignore_global`
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

### 新規 project を初期化する
```sh
mkdir my-project
cd my-project
dotfiles project
```

既存ファイルは上書きせず skip する。
コピー後は `AGENTS.md`, `README.md`, `docs/` の TODO を project 固有の内容に書き換える。

### 管理対象ファイルを増やす
1. repo に設定ファイルを置く
2. `bin/dotfiles` の `link_all` に symlink を追加する
3. `dotfiles link` を実行する

## Details
- [`bin/README.md`](bin/README.md)
- [`git/README.md`](git/README.md)
- [`zsh/README.md`](zsh/README.md)
- [`project/README.md`](project/README.md)
- [`vscode/README.md`](vscode/README.md)
- [`ghostty/README.md`](ghostty/README.md)
- [`lazygit/README.md`](lazygit/README.md)
- [`mise/README.md`](mise/README.md)
