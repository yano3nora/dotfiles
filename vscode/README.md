# VSCode

## Overview

VSCode user settings managed by this repository.

Managed files:

- `settings.json`
- `keybindings.json`
- `github-markdown.css`
- `extensions.txt` - 導入している拡張の一覧 (`code --list-extensions`)

`dots link` links settings and keybindings into VSCode's user config directory.

## Getting Started

```sh
brew bundle    # cask "visual-studio-code"
dots link
xargs -L1 code --install-extension < vscode/extensions.txt
```

Settings Sync は symlink した `settings.json` と競合するので使わない。拡張の追加・削除をしたら `code --list-extensions | sort > vscode/extensions.txt` で更新する。

## Setup / Basic Usage

The markdown preview stylesheet is loaded through jsDelivr because local file references are restricted in VSCode webviews.

- CSS URL: `https://cdn.jsdelivr.net/gh/yano3nora/dotfiles@main/vscode/github-markdown.css`
- Purge cache: `https://purge.jsdelivr.net/gh/yano3nora/dotfiles@main/vscode/github-markdown.css`

## Important Commands

```sh
dots link
```

## Trouble Shooting

If settings are not reflected, confirm symlinks:

```sh
readlink "$HOME/Library/Application Support/Code/User/settings.json"
readlink "$HOME/Library/Application Support/Code/User/keybindings.json"
```

## My Recommendation

Keep detailed VSCode behavior in `settings.json` comments where possible. This README should stay as an entrypoint only.
