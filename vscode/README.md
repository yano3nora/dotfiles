# VSCode

## Overview

VSCode user settings managed by this repository.

Managed files:

- `settings.json`
- `keybindings.json`
- `github-markdown.css`

`dotfiles link` links settings and keybindings into VSCode's user config directory.

## Getting Started

```sh
dotfiles link
```

## Setup / Basic Usage

The markdown preview stylesheet is loaded through jsDelivr because local file references are restricted in VSCode webviews.

- CSS URL: `https://cdn.jsdelivr.net/gh/yano3nora/dotfiles@main/vscode/github-markdown.css`
- Purge cache: `https://purge.jsdelivr.net/gh/yano3nora/dotfiles@main/vscode/github-markdown.css`

## Important Commands

```sh
dotfiles link
```

## Trouble Shooting

If settings are not reflected, confirm symlinks:

```sh
readlink "$HOME/Library/Application Support/Code/User/settings.json"
readlink "$HOME/Library/Application Support/Code/User/keybindings.json"
```

## My Recommendation

Keep detailed VSCode behavior in `settings.json` comments where possible. This README should stay as an entrypoint only.
