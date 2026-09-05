# lazygit

## Overview

LazyGit configuration managed by this repository.

Managed file:

- `config.yml`

`dots link` links it into LazyGit's macOS Application Support config path.

## Getting Started

```sh
dots link
```

## Setup / Basic Usage

Config path:

```txt
~/Library/Application Support/lazygit/config.yml
```

Current config uses:

- `coda` as editor (custom `os.edit`, vim-compatible `+N` line jump)
- `hunk` as diff renderer (`git.diffRenderers`)

## Important Commands

```sh
lazygit
```

## Trouble Shooting

Confirm the symlink:

```sh
readlink "$HOME/Library/Application Support/lazygit/config.yml"
```

If diff rendering does not work, check `hunk`:

```sh
which hunk
hunk pager --help
```

## My Recommendation

Keep only stable LazyGit preferences here. Avoid storing temporary experiments or machine-local notes in `config.yml`.
