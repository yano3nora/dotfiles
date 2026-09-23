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
    - `dots mcp [on|off]` - switch MCP servers / claude.ai connectors for claude + codex at once
- `isodate` - epoch milliseconds to ISO datetime
- `safezip` - create NFC / UTF-8 zip archives
- `ffcomp` - quick H.264/AAC mp4 re-encode
- `ppt2png` - export pptx / pdf pages to png at a given scale via PowerPoint + poppler (macOS only)
- `pdf2png` - export pdf pages to png at a given scale via poppler (bash, macOS / Windows git bash)
- `gsheet` - read / write Google Sheets cells via Sheets REST API with gcloud credentials (see below)

## gsheet setup

`gsheet` は gcloud 内蔵の OAuth client で認可する。OAuth 同意画面や client の自作は要らない。
Sheets API は無料。請求先アカウントも要らない。1 回だけ次を実行する:

```sh
brew bundle                                  # gcloud-cli
gcloud auth login --enable-gdrive-access     # 内蔵 client で drive scope を取る
gcloud projects create <project-id>          # 割り当て先。Sheets 専用にしておく
gcloud config set project <project-id>
gcloud services enable sheets.googleapis.com
```

確認:

```sh
gsheet meta https://docs.google.com/spreadsheets/d/<id>/edit
```

- scope は `drive` 全体になる。理由: 内蔵 client で取れる Drive 系 scope はこれだけ。`spreadsheets` だけに絞るには自作 OAuth client と ADC が要る
- 資格情報は `~/.config/gcloud/` に残る。自分の Drive 全体に効くので扱いは他の gcloud 資格情報と同じ
- ファイル名からの検索は `gsheet` ではやらない。claude.ai の Google Drive connector に任せる
- Agent 向けの使い方は `ai/skills/gsheet/SKILL.md`

## pdf2png on Windows (git bash)

1. Install poppler:

    ```sh
    winget install oschwartz10612.Poppler
    ```

2. Put `bin/pdf2png` somewhere on your PATH, e.g. `~/bin/pdf2png`, and `chmod +x` it.
3. Run:

    ```sh
    pdf2png -s 2 slides.pdf 1-3 6   # -> slides_p1.png ... slides_p6.png (2x)
    ```

If `pdftoppm` is not found after install, add poppler's `Library/bin` directory to PATH and reopen git bash.

## Trouble Shooting

If a new command is not found:

1. Check it is executable: `ls -l bin/<name>`
2. Run: `dots link`
3. Check: `which <name>`

## My Recommendation

Use `dots addbin <name>` instead of creating files manually. It avoids forgetting `chmod +x`.
