# dotfiles

Personal dotfiles for macOS.

## Overview

This repository manages:

- `zsh/` - zsh loader, shell setup, aliases, and shell functions
- `bin/` - personal executable commands linked into `~/.local/bin`
- `vscode/` - VSCode user settings and keybindings
- `ghostty/` - Ghostty terminal config
- `lazygit/` - LazyGit config

The main entrypoint is `bin/dotfiles`.

## Getting Started

```sh
git clone xxx
cd dotfiles
./bin/dotfiles link
exec $SHELL -l
```

`dotfiles link` creates symlinks and backs up existing files as `.bak.YYYYMMDDHHMMSS`.

## Basic Usage

```sh
dotfiles link           # managed files を symlink する
dotfiles doctor         # 必要なコマンドの有無を確認する
dotfiles addbin <name>  # bin/<name> を実行可能な雛形つきで作る
```

`dotfiles link` が作成する主なリンク:

- `~/.config/dotfiles` -> this repository
- `~/.zshrc` -> `zsh/zshrc`
- `~/.local/bin/*` -> `bin/*`
- VSCode settings / keybindings
- Ghostty config
- LazyGit config

## Common Workflows

### zsh 設定を追加・変更する

`zsh/zshrc.d/*.zsh` を編集する。

反映:

```sh
reload
```

または:

```sh
exec $SHELL -l
```

### 新しい個人コマンドを追加する

```sh
dotfiles addbin my-command
# bin/my-command を編集する
dotfiles link
```

`addbin` は `chmod +x` 済みの雛形を作る。手で作った場合は自分で `chmod +x bin/<name>` する。

### 新しい管理対象ファイルを増やす

1. repo に設定ファイルを置く
2. `bin/dotfiles` の `link_all` に symlink 対象を追加する
3. `dotfiles link` を実行する

## Managed Areas

See each directory README:

- [`bin/README.md`](bin/README.md)
- [`zsh/README.md`](zsh/README.md)
- [`vscode/README.md`](vscode/README.md)
- [`ghostty/README.md`](ghostty/README.md)
- [`lazygit/README.md`](lazygit/README.md)

## My Recommendation

普段は `dotfiles link` と `reload` だけ覚えればよい。
依存コマンドを増やしたときだけ `dotfiles doctor` を見る。
