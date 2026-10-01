# TASK-261001: Windows サブ機の最低限セットアップ

261001 Windows サブ機の最低限セットアップ
===

## asis

- dotfiles は macOS 専用。`dots` / zsh / Brewfile 前提で、Windows では動かない
- Windows 側の前提: Windows 11 Home、WSL2 なし、git bash と winget と mise あり
- `bin/gsheet`, `bin/pdf2png` は git bash 対応済み (TASK-260930)
- `~/.gitconfig`, `~/.claude/CLAUDE.md` は未作成。`~/.config/mise/config.toml` は node のみ

## tobe

- Windows はサブ機として必要最低限だけ揃える。手順は `windows/README.md` 1 枚で追える
- 設定ファイルは `windows/copy-configs.sh` (git bash) で repo -> HOME に一方通行でコピーする
    - 理由: Windows の symlink は開発者モードか管理者権限が要る。サブ機なので drift は再実行で吸収する
    - 名前は `install` を避ける (AGENTS.md の方針)
- mac の設定を Windows 用に変える場合は `windows/` に別ファイルを置く。mac 側のファイルは変えない
    - `windows/gitconfig`: `git/gitconfig` を include し、`core.pager` だけ less に上書き。理由: hunk は mise registry に無く Windows で入らない
    - `windows/mise.toml`: サブ機用に絞った global tool。理由: mac の config を共有すると Windows で入らない tool で `mise install` が止まる

## todo

- [x] `windows/copy-configs.sh`, `windows/gitconfig`, `windows/mise.toml` を作る
- [x] `windows/README.md` に「mac から持っていくもの」と Getting Started を書く
- [x] root `README.md` / `AGENTS.md` に `windows/` を足す
- [x] 実機で `copy-configs.sh` を流す
- [x] 実機で `cd ~ && mise install`
- [ ] VSCode 拡張を入れる。Windows で不要なもの (php / xdebug など) を入れるか判断する
- [ ] `~/.local/bin` が Windows のユーザー PATH に入っているか確認する (PowerShell から `gsheet.cmd`)
- [x] CapsLock は Scancode Map で左 Ctrl (一度 Alt にしたが terminal 操作が揃わないので戻した)
- [x] VSCode keybindings は mac cmd -> ctrl に読み替える。mac ctrl と Windows 標準がぶつかる `ctrl+f` `ctrl+d` `ctrl+i` `ctrl+[` `ctrl+]` は Windows 標準を優先し、mac 側の割り当てを `alt+X` に逃がす (`j/k/h/l` などは mac 側を優先)
- [x] VSCode settings は `windows/vscode-settings.json` を jq で上書き merge する (フォントサイズ、既定ターミナルを Git Bash、`alt+f` などでメニューを開かない)
- [ ] 他にも Windows 標準を優先したい ctrl+X があれば `WINDOWS_STANDARD_CTRL_KEYS` に足す
- [ ] 必要になったら: lazygit の Windows 用 config

## testcases

- [x] 一時 HOME / APPDATA で `copy-configs.sh` を流し、全ファイルがコピーされる
- [x] 再実行で全件 `unchanged` になり、`.bak` が増えない
- [x] 既存ファイルがあれば `.bak.YYYYMMDDHHMMSS` に退避される
- [x] `GIT_CONFIG_GLOBAL=<コピー先>` で `core.pager` が `less`、`user.name` / alias が include から読める
- [x] 実機で `git var GIT_PAGER` が `less` になり、less が PATH にある (実際の表示は端末で目視)

## notes

- repo を cwd にして `mise` を叩くと、`mise/config.toml` が project config として読まれる (mise は `<dir>/mise/config.toml` を拾う)。Windows で入らない hunk などの warning が出るので、`mise install` は HOME で流す
- `coda` / `leaf` / `gistan` の config は Windows での読み先 (`~/.config` か `%APPDATA%` か) を未確認なので持っていかない
- lazygit の config 置き場は `%LOCALAPPDATA%\lazygit` (`lazygit --print-config-dir` で確認)
- 未認証の GitHub API は rate limit に当たりやすい。`mise install` が 403 で落ちたら `GITHUB_TOKEN="$(gh auth token)" mise install` で流し直す
- 261001: repo を cwd にして jq を叩いたら、mise が mac 用の `mise/config.toml` から aws-sam-cli と pdm を auto install した。`copy-configs.sh` は先頭で `cd "$HOME"` する
- CapsLock = Alt 案は捨てた。VSCode の keybindings は揃うが、terminal (bash の Ctrl 系) は読み替えられず、指の位置が揃わない
- mac は ctrl (CapsLock) と cmd が別キーだが、Windows ではどちらも ctrl になる。mac の ctrl+X 独自割り当てと Windows 標準 ctrl+X (mac の cmd+X) はどちらか一方しか取れないので、Windows 標準を優先するキーを `WINDOWS_STANDARD_CTRL_KEYS` で選び、mac 側を alt+X に逃がす
- `cmd+h/l` (1 文字移動) は `ctrl+h/l` (単語移動) と重なり、後勝ちで単語移動になる
- Windows 側で直接 mise config (codex 追加) と VSCode のフォントサイズを変えていたのを、`copy-configs.sh` の再実行で 2 回上書きした (.bak から repo の windows/ 側に反映済み)。Windows で直接いじる運用になるなら、上書き前に差分を出すか止める仕組みを検討する
