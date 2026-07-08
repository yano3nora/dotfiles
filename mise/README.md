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

Moved to mise:

- `deno@1.40.5`
- `jq` (`latest`)
- `ripgrep` (`latest`)
- `java@openjdk-25.0.2`

Homebrew cleanup status:

- `deno` was uninstalled from Homebrew.
- `jq` and `ripgrep` are still installed by Homebrew because Homebrew refused to remove them as dependencies of other installed formulae (`codex` / `ijq`). The interactive shell still resolves them through mise, so this is acceptable for now.

## My Recommendation

Keep the policy lightweight. Over-pinning every small CLI creates busywork without much benefit; pin only where compatibility or deployment behavior can actually hurt you.
