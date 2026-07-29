# bin

## Overview

Personal executable commands.

`dots link` links executable files in this directory to `~/.local/bin`.

## Getting Started

Create a new command with:

```sh
dots addbin my-command
```

Then edit:

```sh
bin/my-command
```

## Basic Usage

```sh
dots addbin my-command  # create executable template
dots link               # link bin/* to ~/.local/bin
```

If you create a file manually, remember:

```sh
chmod +x bin/my-command
dots link
```

## Important Commands

- `dots` - dotfiles management command
    - `dots project [dir]` - copy new-project templates without overwriting existing files
- `isodate` - epoch milliseconds to ISO datetime
- `safezip` - create NFC / UTF-8 zip archives
- `ffcomp` - quick H.264/AAC mp4 re-encode
- `mactune` - macOS tweaks
    - `mactune duet status|off|on` - manage `duetexpertd`
    - `mactune ui status` - inspect the main macOS UI processes
    - `mactune ui refresh` - restart only auto-recovering UI processes without closing apps
    - `mactune chrome-cache status [--all]` - inspect removable Chrome cache usage
    - `mactune chrome-cache clear [--all] [--yes]` - remove Chrome caches after Chrome is closed

`mactune ui refresh` does not restart `WindowServer` because doing so ends the login
session. It is useful when Dock, the menu bar, or notifications are stuck, but it is
not a general CPU or memory cleaner.

`mactune chrome-cache clear` removes only HTTP and GPU caches. Add `--all` to
also remove Service Worker cache storage. The latter can contain offline site data,
so confirm that offline documents are synchronized first. Cookies, history,
bookmarks, saved passwords, and session data are outside the deletion targets.

## Trouble Shooting

If a new command is not found:

1. Check it is executable: `ls -l bin/<name>`
2. Run: `dots link`
3. Check: `which <name>`

## My Recommendation

Use `dots addbin <name>` instead of creating files manually. It avoids forgetting `chmod +x`.
