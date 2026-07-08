# leaf

## Overview

leaf configuration managed by this repository.

Managed file:

- `config.toml`

`dots link` links it into the XDG config path.

## Getting Started

```sh
dots link
```

## Setup / Basic Usage

Config path:

```txt
~/.config/leaf/config.toml
```

Current config uses:

- `ocean` theme
- `vim +{$line} {$path}` as Ctrl+E editor
- file watch mode enabled

## Important Commands

```sh
leaf
```

## Trouble Shooting

Confirm the symlink:

```sh
readlink "$HOME/.config/leaf/config.toml"
```

If the setting is not reflected, confirm leaf is reading the expected XDG config path.

## My Recommendation

Keep this file minimal. The original generated sample had duplicate `watch` keys, which is invalid TOML and should not be committed as-is.
