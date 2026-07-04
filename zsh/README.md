# zsh

## Overview

Zsh configuration is split into a small loader and focused files under `zshrc.d/`.

`dotfiles link` links:

```txt
~/.zshrc -> zsh/zshrc
```

## Getting Started

After linking, reload the shell:

```sh
exec $SHELL -l
```

For normal edits:

```sh
reload
```

## Setup / Basic Usage

`zsh/zshrc` loads every `zsh/zshrc.d/*.zsh` file in filename order.

Current structure:

- `00-initial.zsh` - initialization that must run first
- `10-tool.zsh` - PATH and external tool setup
- `20-zsh.zsh` - oh-my-zsh / p10k / completion / zle setup
- `30-alias.zsh` - aliases and editor settings
- `40-func-*.zsh` - shell functions, split by purpose

## Important Commands

```sh
reload          # exec current shell as login shell
zsh -n <file>   # syntax check
```

## Topics / How to

### Add a function

Create a file like:

```txt
zsh/zshrc.d/44-func-example.zsh
```

Use a filename that makes the function purpose obvious.

### Add an alias

Edit:

```txt
zsh/zshrc.d/30-alias.zsh
```

## Trouble Shooting

If shell startup breaks, run syntax checks:

```sh
zsh -n zsh/zshrc
for f in zsh/zshrc.d/*.zsh; do zsh -n "$f" || break; done
```

## My Recommendation

Keep `10-tool.zsh` for external dependencies, `30-alias.zsh` for short aliases, and create one `40-func-*.zsh` file per meaningful function group.
