# nvim

## Overview

[LazyVim](https://www.lazyvim.org/) の個人カスタマイズ部分だけを管理する。
`~/.config/nvim` 自体は [LazyVim/starter](https://github.com/LazyVim/starter) を直接 clone した実体で、この repo の管理対象ではない。

Managed files:

- `lua/config/options.lua`
- `lua/config/keymaps.lua`
- `lua/config/autocmds.lua`
- `lua/plugins/blink.lua`

`init.lua`, `lua/config/lazy.lua`, `lazy-lock.json`, `lazyvim.json`, `stylua.toml`, `.neoconf.json` などは starter 標準のままなので管理しない。

## Getting Started

```sh
# 新規環境では先に starter を clone しておく
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git

dots link
```

## Setup / Basic Usage

### wrap / spell を切っている理由

LazyVim の default は `lazyvim_wrap_spell` という augroup で `text` / `markdown` / `gitcommit` などの filetype に `wrap` と `spell` を自動で有効にする。
日本語テキストが spell check に引っかかって赤線だらけになるだけで嬉しさがなく、wrap も不要なため、`autocmds.lua` で該当 augroup を丸ごと削除している。

## Trouble Shooting

反映されない場合は symlink を確認する:

```sh
readlink ~/.config/nvim/lua/config/options.lua
readlink ~/.config/nvim/lua/config/autocmds.lua
```

## My Recommendation

`lua/plugins/example.lua` のように LazyVim starter がそのまま使う想定のファイルは、個人カスタマイズが入るまでここに置かない。
