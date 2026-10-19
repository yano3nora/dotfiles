# TASK-261019: `gsheet` を廃止する

261019 `gsheet` を廃止する
===

## asis

- `gsheet` は submodule `ai/skills/yano3nora/skills/gsheet/` にある。Google Sheets を curl で読み書きする bash 製 CLI
- 作った理由は「claude.ai の Drive connector が閲覧専用」だった
- 2026-10-07 に Google Sheets connector が Claude Code で読み書きできると確認した。前提が崩れた
- 残す理由だった Codex 経路も、使う場面が無い
- 付随物: Brewfile の `gcloud-cli`、`~/.claude/settings.json` の `"gsheet *"` 除外、鍵 JSON `~/.config/gsheet/key.json`、GCP のサービスアカウント `claude`

## tobe

- Google Sheets は Claude Code の connector だけで扱う。CLI は持たない
- submodule から `skills/gsheet/` を消す。`install.sh` と `dots link` の仕組みは汎用なので変えない
- dotfiles 側は gsheet 前提の記述を消す。過去の TASK docs は記録として残す

## todo

- [x] submodule: `skills/gsheet/` を削除。README と `install.sh` の例から gsheet を外す
- [x] Brewfile から `gcloud-cli` を外す。理由: 鍵作成にしか使っていなかった
- [x] `bin/README.md`, `windows/README.md`, `ai/README.md` から gsheet の記述を外す
- [x] 実 HOME の symlink を消す: `~/.local/bin/gsheet*`, `~/.claude/skills/gsheet`, `~/.codex/skills/gsheet`
- [ ] 人間: `~/.claude/settings.json` の `excludedCommands` から `"gsheet *"` を消す
- [ ] 人間: `brew uninstall --cask gcloud-cli`
- [ ] 人間: `~/.config/gsheet/key.json` を消す。GCP 側でサービスアカウント `claude` の鍵も失効させる
- [ ] 人間: submodule を commit / push し、dotfiles 側も commit する
- [ ] 人間: Windows サブ機で `copy-configs.sh` を流し、`~/.local/bin/gsheet*` と `~/.codex/skills/gsheet` を手で消す。理由: `install.sh` は消さない

## testcases

- [x] `bash -n ai/skills/yano3nora/install.sh` / `zsh -n bin/dots` / `dots doctor`
- [x] 一時 HOME で `dots link` を流し、`gsheet` の symlink が作られない
- [x] `grep -rn gsheet` が docs/ と `.git` 以外で 0 件

## notes

- 配布先が `git pull && ./install.sh` しても、入れ済みの gsheet は消えない。`install.sh` は追加とバックアップしかしない。各自で消す
- Zenn の Windows セットアップ記事は gsheet を前提にしない。skill の例として触れていれば直す
