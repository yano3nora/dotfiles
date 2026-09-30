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
- `gsheet` - read / write Google Sheets cells via Sheets REST API with gcloud or a service account key (bash, macOS / Windows git bash, see below)

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

## gsheet with a service account (no gcloud)
`GOOGLE_APPLICATION_CREDENTIALS` にサービスアカウントの鍵 JSON を置くと、`gsheet` は gcloud を使わない。
openssl で JWT を署名して token を取り、scope は `spreadsheets` だけになる。複数人に配るときはこちらを使う。

```sh
gcloud iam service-accounts create gsheet --project <project-id>
gcloud iam service-accounts keys create ~/Downloads/gsheet-key.json \
  --iam-account=gsheet@<project-id>.iam.gserviceaccount.com
export GOOGLE_APPLICATION_CREDENTIALS=~/Downloads/gsheet-key.json
gsheet meta <id>
```

- 対象の spreadsheet を、鍵の `client_email` に「編集者」で共有する。サービスアカウントは共有されたものしか触れない
- 依存は `curl`, `jq`, `openssl`。`curl` と `openssl` は git bash に入っている。`jq` は mise で入れる
- quota header は送らない。理由: 割り当て先は鍵の project に決まる。IAM の追加は要らない
- 鍵 JSON は秘密鍵。配った鍵は用が済んだら `gcloud iam service-accounts keys delete` で消す
- 誰が書いたかは区別できない。全員が同じサービスアカウントとして書く

## gsheet on Windows (git bash)
WSL2 は使わない。git bash と mise が入っている前提。資格情報は Mac からコピーせず、Windows で login し直す。
理由: `~/.config/gcloud/` の refresh token は自分の Drive 全体に効く。GCP project は Mac と同じものを使う。

1. Install gcloud:

    ```sh
    winget install Google.CloudSDK
    ```

2. Reopen git bash and check `gcloud --version`. If not found, add `Google\Cloud SDK\google-cloud-sdk\bin` to PATH.
3. Authorize with the same project as macOS:

    ```sh
    gcloud auth login --enable-gdrive-access
    gcloud config set project <project-id>
    ```

4. Install `jq` via mise, then put `bin/gsheet` and `bin/gsheet.cmd` in `~/bin` and `chmod +x ~/bin/gsheet`.
5. Add `%USERPROFILE%\bin` and `%LOCALAPPDATA%\mise\shims` to the Windows user PATH. Run this in a PowerShell window, then reopen git bash:

    ```powershell
    [Environment]::SetEnvironmentVariable('Path', "$env:USERPROFILE\bin;$env:LOCALAPPDATA\mise\shims;" + [Environment]::GetEnvironmentVariable('Path','User'), 'User')
    ```

6. Run from git bash and from PowerShell:

    ```sh
    gsheet meta https://docs.google.com/spreadsheets/d/<id>/edit
    powershell -Command "gsheet meta https://docs.google.com/spreadsheets/d/<id>/edit"
    ```

- `gsheet.cmd` は PowerShell / cmd からの入口。Codex は Windows では PowerShell でコマンドを実行するので、Agent はこの経路で呼ぶ
    - `~/.bashrc` の PATH は PowerShell に効かない。理由: 手順 5 で Windows 側の PATH に足すのはそのため
- Agent は JSON を `'@<file>'` で渡し、`<sheet>` は ID で渡す。理由: PowerShell → cmd → bash の経路で引用符が壊れ、cmd が `&` を区切りと解釈する
- `gsheet.cmd` は `CHERE_INVOKING=1` を立てる。理由: login shell は HOME へ cd するので、相対の `@file` が読めなくなる
- `gcloud` の出力に付く `\r` は `gsheet` 側で除いている。header に混ざると curl が落ちる
- Windows の Claude Code には sandbox が無い。`excludedCommands` の設定は要らない
- サービスアカウントで使うなら手順 1〜3 は不要。鍵 JSON を置き、`GOOGLE_APPLICATION_CREDENTIALS` を Windows のユーザ環境変数に設定する。理由: Codex の PowerShell に `~/.bashrc` の export は効かない

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
