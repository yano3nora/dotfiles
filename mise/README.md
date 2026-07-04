# mise

## Overview

Global CLI tool versions are managed by mise.

This dotfiles repository manages the global mise config:

```txt
mise/config.toml -> ~/.config/mise/config.toml
```

Project-local tool versions should be managed by each project's `mise.toml`, not here.

## Getting Started

```sh
dotfiles link
mise install
```

## Setup / Basic Usage

Global tools are defined in:

```txt
mise/config.toml
```

Do not use `latest` for tool versions. Pin explicit versions to keep the environment reproducible.

## Important Commands

```sh
mise install      # install tools from ~/.config/mise/config.toml
mise current      # show active tool versions
mise list         # show installed versions
mise use -g tool@version
```

## Topics / How to

### Add a global CLI tool

1. Add a pinned version to `mise/config.toml`
2. Run `dotfiles link`
3. Run `mise install`
4. Run `dotfiles doctor` if the command is required by this environment

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

Moved to mise:

- `deno@1.40.5`
- `jq@1.7.1`
- `ripgrep@15.1.0`

Homebrew cleanup status:

- `deno` was uninstalled from Homebrew.
- `jq` and `ripgrep` are still installed by Homebrew because Homebrew refused to remove them as dependencies of other installed formulae (`codex` / `ijq`). The interactive shell still resolves them through mise, so this is acceptable for now.

## My Recommendation

Use this README for mise-specific commands and migration notes. See the root README for the overall dotfiles tool-management policy and exceptions.
