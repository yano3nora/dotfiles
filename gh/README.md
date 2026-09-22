# gh

## Overview

GitHub CLI (`gh`) の設定と拡張一覧を管理する。

Managed files:

- `config.yml` - alias などの設定。`dots link` で `~/.config/gh/config.yml` へ symlink する
- `extensions.txt` - 導入している拡張の一覧 (`gh extension list`)

`hosts.yml` は OAuth token を含むため管理しない。`gh auth login` で作る。

## Getting Started

```sh
mise install    # gh は mise/config.toml で管理する
dots link
gh auth login
xargs -L1 gh extension install < gh/extensions.txt
```

## Setup / Basic Usage

拡張の追加・削除をしたら一覧を更新する。

```sh
gh extension list | cut -f2 | sort > gh/extensions.txt
```

## Important Commands

```sh
gh extension list
gh extension upgrade --all
```

## Trouble Shooting

設定が反映されない場合は symlink を確認する。

```sh
readlink ~/.config/gh/config.yml
```

## My Recommendation

拡張のインストールは `dots` に組み込まない。一覧と README のコマンドで十分に思い出せる。
