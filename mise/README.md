# mise

## Overview

Global CLI tools and selected runtime versions are managed by mise.

This dotfiles repository manages the global mise config:

```txt
mise/config.toml -> ~/.config/mise/config.toml
```

Project-local tool versions should be managed by each project's `mise.toml`, not here.

## Getting Started

```sh
dots link
mise install
```

## Setup / Basic Usage

Global tools are defined in:

```txt
mise/config.toml
```

Version policy:

- Daily utility CLIs such as `jq`, `ripgrep`, `hunk`, `gitleaks`, and `leaf` may use `latest`.
- Runtimes and project-impacting tools such as Node, Python, Java, and deploy/vendor CLIs should use explicit versions when compatibility matters.
- Project-specific versions belong in each project's `mise.toml`, not this global config.

## Important Commands

```sh
mise install      # install tools from ~/.config/mise/config.toml
mise current      # show active tool versions
mise list         # show installed versions
mise use -g tool@version
```

## Topics / How to

### Add a global CLI tool

1. Add the tool to `mise/config.toml`
    - use `latest` for low-risk daily utilities
    - use an explicit version for runtimes or deploy/project-impacting CLIs
2. Run `dots link`
3. Run `mise install`
4. Run `dots doctor` if the command is required by this environment

### Project-local tools

Use the project's own `mise.toml`.
Do not put project-specific versions in this global config.

## Trouble Shooting

If a command still resolves to Homebrew after moving it to mise:

```sh
which <command>
mise doctor
```

Then check whether old PATH entries remain in `zsh/zshrc.d/10-tool.zsh`.

## Homebrew migration status

Daily CLIs are moved to mise whenever a prebuilt binary is available. The remaining Homebrew formulae live in the root `Brewfile` and are limited to build / OS dependent tools (`ffmpeg`, `imagemagick`, `trash`, `zip`, `convmv`, ...), GUI apps, and fonts.

Moved to mise:

- runtimes: `deno`, `java`, `node`, `python`, `uv`
- daily CLIs: `jq`, `ripgrep`, `gh`, `bat`, `direnv`, `fd` (`ubi`), `fzf`, `lazygit`, `peco`, `fastfetch`, `yazi`, `gitleaks`, `aws-cli`
- python tools: `pdm` (`pipx` backend via `uv`)

Kept in Homebrew (see `Brewfile`):

- `trash`, `zip`, `convmv`, `coreutils`, `ffmpeg`, `imagemagick`, `ghostscript`, `exiftool`, `wget`, `btop`, `pv`

Not managed (install individually when needed): `php`, `git-lfs`, GNU `grep`.

GNU `coreutils` is in `Brewfile`, but its `gnubin` is not added to PATH. Commands that macOS also has use the `g` prefix (`gdate`). Commands that macOS lacks (`timeout`, `nproc`) are linked without prefix by brew.

Rules:

- when adding a tool, decide mise or Homebrew and uninstall the other. Do not keep both.
- never write the Homebrew prefix (`/usr/local` on Intel, `/opt/homebrew` on Apple Silicon) into `zsh/`. Both machines share this repository; brew-managed commands are used through PATH only.
- `ubi:sharkdp/fd` exists because aqua's `fd` has no darwin/amd64 build. Revisit once Intel is retired.

## My Recommendation

Keep the policy lightweight. Over-pinning every small CLI creates busywork without much benefit; pin only where compatibility or deployment behavior can actually hurt you.
