# gistan

## Overview

gistan configuration managed by this repository.

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
~/.config/gistan/config.toml
```

Current config uses:

- `/Users/y3n/git/yano3nora/gists` as the local gist repo
- `leaf` as the viewer

## Important Commands

```sh
gistan root path
gistan list
```

## Trouble Shooting

Confirm the symlink:

```sh
readlink "$HOME/.config/gistan/config.toml"
```

If `gistan list` shows 0 gists, confirm `repo` is an absolute path.
gistan does not expand `$HOME` or `~` in `config.toml`.

## My Recommendation

Keep `repo` absolute. `$HOME` looks portable but silently points gistan at a missing directory.
