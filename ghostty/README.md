# Ghostty

## Overview

Ghostty terminal configuration managed by this repository.

Managed file:

- `config.ghostty`

`dotfiles link` links it into Ghostty's Application Support directory.

## Getting Started

```sh
dotfiles link
```

## Setup / Basic Usage

Config path:

```txt
~/Library/Application Support/com.mitchellh.ghostty/config.ghostty
```

## Important Commands

```sh
dotfiles link
```

## Trouble Shooting

Confirm the symlink:

```sh
readlink "$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty"
```

## My Recommendation

Keep Ghostty-specific notes close to `config.ghostty` or in this README. Do not expand the top-level README for terminal-specific details.
