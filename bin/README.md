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
- `gsheet` - read / write Google Sheets cells via Sheets REST API with a service account key (bash, macOS / Windows git bash, see below)

## gsheet setup

`gsheet` はサービスアカウントの鍵 JSON で認可する。鍵は `~/.config/gsheet/key.json` に置く。
gcloud は鍵を作るときだけ使う。実行時の依存は `curl`, `jq`, `openssl` だけ。Sheets API は無料で、請求先アカウントも要らない。

鍵は 1 回だけ作る:

```sh
brew bundle                                                   # gcloud-cli
gcloud auth login
gcloud projects create <project-id>                           # 無ければ作る。Sheets 専用にしておく
gcloud services enable sheets.googleapis.com --project <project-id>
gcloud iam service-accounts create gsheet --project <project-id>
mkdir -p ~/.config/gsheet
gcloud iam service-accounts keys create ~/.config/gsheet/key.json \
  --iam-account=gsheet@<project-id>.iam.gserviceaccount.com
```

対象の spreadsheet を、鍵の `client_email` に「編集者」で共有する。サービスアカウントは共有されたものしか触れない:

```sh
jq -r .client_email ~/.config/gsheet/key.json      # この address に共有する
```

動作を確認する:

```sh
gsheet meta https://docs.google.com/spreadsheets/d/<id>/edit
```

- scope は `spreadsheets` だけ。自分の Drive 全体には効かない
- 誰が書いたかは区別できない。全員が同じサービスアカウントとして書く
- 別の鍵を一時的に使うときだけ `GOOGLE_APPLICATION_CREDENTIALS` でパスを上書きする。shell 全体に立てない。理由: 他の Google SDK もこの変数を読む
- 鍵 JSON は秘密鍵。配った鍵は用が済んだら `gcloud iam service-accounts keys delete` で消す
- 割り当て先 project の header は送らない。理由: 割り当て先は鍵の project に決まる。IAM の追加は要らない
- ファイル名からの検索は `gsheet` ではやらない。claude.ai の Google Drive connector に任せる
- Agent 向けの使い方は `ai/skills/gsheet/SKILL.md`

## gsheet on Windows (git bash)
WSL2 は使わない。git bash と mise が入っている前提。gcloud は要らない。鍵 JSON は Mac で作ったものを置く。

1. Install `jq` via mise, then put `bin/gsheet` and `bin/gsheet.cmd` in `~/bin` and `chmod +x ~/bin/gsheet`.
2. Add `%USERPROFILE%\bin` and `%LOCALAPPDATA%\mise\shims` to the Windows user PATH. Run this in a PowerShell window, then reopen git bash and PowerShell:

    ```powershell
    [Environment]::SetEnvironmentVariable('Path', "$env:USERPROFILE\bin;$env:LOCALAPPDATA\mise\shims;" + [Environment]::GetEnvironmentVariable('Path','User'), 'User')
    ```

3. Put the key JSON at `%USERPROFILE%\.config\gsheet\key.json`. git bash resolves `~` to `%USERPROFILE%`, so no environment variable is needed.
4. Run from git bash and from PowerShell:

    ```sh
    gsheet meta https://docs.google.com/spreadsheets/d/<id>/edit
    powershell -Command "gsheet meta https://docs.google.com/spreadsheets/d/<id>/edit"
    ```

- `gsheet.cmd` は PowerShell / cmd からの入口。Codex は Windows では PowerShell でコマンドを実行するので、Agent はこの経路で呼ぶ
- Agent は JSON を `'@<file>'` で渡し、`<sheet>` は ID で渡す。理由: PowerShell → cmd → bash の経路で引用符が壊れ、cmd が `&` を区切りと解釈する
- `gsheet.cmd` は `CHERE_INVOKING=1` を立てる。理由: login shell は HOME へ cd するので、相対の `@file` が読めなくなる
- Windows の Claude Code には sandbox が無い。`excludedCommands` の設定は要らない

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
