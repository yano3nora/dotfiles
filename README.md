# dotfiles

Personal dotfiles for macOS.

This dotfiles setup assumes `mise` is installed. Global CLI tools are managed by mise via `mise/config.toml`; project-local tool versions should live in each project's own `mise.toml`.

## Overview

This repository manages:

- `zsh/` - zsh loader, shell setup, aliases, and shell functions
- `bin/` - personal executable commands linked into `~/.local/bin`
- `vscode/` - VSCode user settings and keybindings
- `ghostty/` - Ghostty terminal config
- `lazygit/` - LazyGit config
- `mise/` - global mise tool config

The main entrypoint is `bin/dotfiles`.

## Getting Started

```sh
git clone xxx
cd dotfiles
./bin/dotfiles link
mise install
dotfiles doctor
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
- `~/.config/mise/config.toml` -> `mise/config.toml`
- `~/.local/bin/*` -> `bin/*`
- VSCode settings / keybindings
- Ghostty config
- LazyGit config

## Tool Management Policy

This dotfiles setup uses `mise` for ordinary global CLI tools and runtimes.
Project-local tool versions should live in each project's own `mise.toml`.

Not everything should be forced into mise. Current exceptions:

- `php@8.1` - kept on Homebrew. `mise install php@8.1.32` tried to build PHP from source and failed because `autoconf` was missing. PHP builds have many native dependencies, so the Homebrew PHP PATH stays until this is intentionally revisited.
- GNU grep / zip and other macOS command replacements - kept on Homebrew + zsh PATH overrides. These are OS command replacement details, not ordinary global runtime versions.
- `jq` / `ripgrep` - configured in mise and resolved through mise in interactive shells, but still installed by Homebrew because other Homebrew formulae depend on them. Do not force-remove them with `--ignore-dependencies`.

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
- [`mise/README.md`](mise/README.md)

## My Recommendation

普段は `dotfiles link` と `reload` を使う。global CLI tool を増やしたときは `mise/config.toml` を更新し、`mise install` と `dotfiles doctor` を実行する。
