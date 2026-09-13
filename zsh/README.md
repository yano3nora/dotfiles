# zsh

## Overview

Zsh configuration is split into a small loader and focused files under `zshrc.d/`.

`dots link` links:

```txt
~/.zshrc -> zsh/zshrc
~/.p10k.zsh -> zsh/p10k.zsh
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

zsh plugin は git submodule として `zsh/plugins/` に置き、`20-zsh.zsh` が `$DOTFILES_ROOT/zsh/plugins/...` を直接 source する。純粋な zsh script なので Intel / Apple Silicon で path が変わらず、brew や手 clone に依存しない。

```txt
zsh/plugins/powerlevel10k/
zsh/plugins/zsh-autosuggestions/
zsh/plugins/zsh-syntax-highlighting/
```

clone 時は `--recurse-submodules` を付ける。付け忘れたら:

```sh
git submodule update --init --depth 1
```

plugin を更新する (年に数回で十分):

```sh
git submodule update --remote --depth 1
```

p10k の設定は `zsh/p10k.zsh`。`p10k configure` は `~/.p10k.zsh` (symlink) 経由で repo に書き込む。p10k は初回のプロンプト描画時に `gitstatusd` バイナリを GitHub から `~/.cache/gitstatus/` へ取得する (arch ごとに自動選択、submodule は汚れない)。オフラインで初回起動すると `gitstatus failed to initialize` が出るが、ネットワークがある状態で `exec zsh` すれば直る。

`zsh/zshrc` loads every `zsh/zshrc.d/*.zsh` file in filename order.

Current structure:

- `00-initial.zsh` - initialization that must run first
- `10-tool.zsh` - PATH and external tool setup (Homebrew prefix は書かない。AGENTS.md 参照)
- `20-zsh.zsh` - zsh-autosuggestions / syntax highlighting / p10k / completion / zle setup
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
