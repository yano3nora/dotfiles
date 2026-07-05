# bin

## Overview

Personal executable commands.

`dotfiles link` links executable files in this directory to `~/.local/bin`.

## Getting Started

Create a new command with:

```sh
dotfiles addbin my-command
```

Then edit:

```sh
bin/my-command
```

## Basic Usage

```sh
dotfiles addbin my-command  # create executable template
dotfiles link               # link bin/* to ~/.local/bin
```

If you create a file manually, remember:

```sh
chmod +x bin/my-command
dotfiles link
```

## Important Commands

- `dotfiles` - dotfiles management command
    - `dotfiles project [dir]` - copy new-project templates without overwriting existing files
- `isodate` - epoch milliseconds to ISO datetime
- `safezip` - create NFC / UTF-8 zip archives
- `ffcomp` - quick H.264/AAC mp4 re-encode

## Trouble Shooting

If a new command is not found:

1. Check it is executable: `ls -l bin/<name>`
2. Run: `dotfiles link`
3. Check: `which <name>`

## My Recommendation

Use `dotfiles addbin <name>` instead of creating files manually. It avoids forgetting `chmod +x`.
