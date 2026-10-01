# Windows

## Overview

Windows はサブ機として、必要最低限の環境だけ用意する。mac の `dots` / zsh / Brewfile は持ち込まない。
shell は git bash、CLI は mise、GUI アプリは winget で入れる。設定ファイルは symlink せず `copy-configs.sh` でコピーする。
正は Windows 11 Home (10.0.26200) の実機。

Managed files:

- `README.md` - このメモ (セットアップ手順 + レジストリなどの OS 設定)
- `copy-configs.sh` - repo の設定ファイルを HOME / AppData にコピーする
- `gitconfig` - `~/.gitconfig`。`git/gitconfig` を include し、Windows で動かない設定だけ上書きする
- `mise.toml` - `~/.config/mise/config.toml`。サブ機用に絞った global tool
- `vscode-settings.json` - `vscode/settings.json` に上書き merge する Windows 用の差分

OS 設定は項目ごとに「目的 / コマンド / 戻し方 / 適用日」を書く。GUI でしか設定できないものは GUI の場所を書く。
コマンドは PowerShell / cmd どちらでも流せる `reg.exe` で書く。HKCU のみなら管理者権限は不要。

## mac から持っていくもの

| 対象 | 扱い |
|---|---|
| `git/gitconfig`, `git/gitignore_global` | `windows/gitconfig` から include。`core.pager` の hunk だけ less に上書き (hunk は Windows で入らない) |
| `gh/config.yml` | そのままコピー |
| `vscode/settings.json` | `windows/vscode-settings.json` を上書き merge して書き出す (フォントサイズ、既定ターミナルを Git Bash、Alt でメニューを開かない設定) |
| `vscode/keybindings.json` | mac cmd -> ctrl に読み替えて書き出す (mac ctrl はそのまま、CapsLock = Ctrl)。Windows 標準を優先したい ctrl+X (今は `f` `d` `i` `[` `]`) は mac 側の割り当てを alt+X に逃がす。`cmd+w` と `cmd+shift+i` は読み替えない。詳細は `copy-configs.sh` のコメント |
| `ai/CLAUDE.md`, `ai/skills/{gsheet,show-me,why-me}` | `~/.claude/`, `~/.codex/` にコピー |
| `bin/{gsheet,gsheet.cmd,pdf2png}` | `~/.local/bin/` にコピー (git bash で動く bash 製のものだけ) |
| `mise/config.toml` | 共有しない。`windows/mise.toml` に絞って別管理 |
| `Brewfile` の codex 経路 | mac と同じく公式 installer で入れる。手順は Getting Started の 6 |
| `lazygit/config.yml` | 持っていかない。hunk と coda 前提。default で使う |
| `ai/skills/chrome-connect`, zsh 製の `bin/*` | 持っていかない。zsh 前提 |
| `zsh/`, `Brewfile`, `macos/`, `ghostty/`, `coda/`, `leaf/`, `gistan/` | 持っていかない |

## Getting Started

前提: git for Windows (git bash) と winget。以下は git bash で流す。

```sh
# 1. mise と GUI アプリ
winget install jdx.mise
winget install Microsoft.VisualStudioCode
# 2. clone (gitconfig の include がこの path 前提)
git clone https://github.com/yano3nora/dotfiles.git ~/git/yano3nora/dotfiles
cd ~/git/yano3nora/dotfiles
# 3. 設定ファイルをコピー (既存は .bak.YYYYMMDDHHMMSS に退避)
./windows/copy-configs.sh
# 4. CLI (repo の mise/config.toml を拾わないよう HOME で流す)
cd ~ && mise install   # 403 (rate limit) なら GITHUB_TOKEN="$(gh auth token)" mise install
# 5. VSCode 拡張
xargs -L1 code --install-extension < ~/git/yano3nora/dotfiles/vscode/extensions.txt
# 6. codex (CLI) は公式 installer で入れる。PATH も installer が通す
powershell -c "irm https://chatgpt.com/codex/install.ps1 | iex"
```

- codex は mise に載せない。理由: mise (aqua) は `codex.exe` 単体しか入れず、補助 exe が無いので起動できない。
- 以前 mise で入れていた場合は、先に `mise uninstall aqua:openai/codex` で消す。理由: mise の shim が installer 版より PATH で優先されることがある。

- `~/.local/bin` が PATH に無ければ通す (`gsheet.cmd` を PowerShell から呼ぶため、Windows のユーザー環境変数 PATH にも入れる)。
- repo 側を更新したら `./windows/copy-configs.sh` をもう一度流す。中身が同じファイルは触らない。
- Windows 側でコピー先を直接編集しても repo には戻らない。残したい変更は repo 側に書いてから流す。
- gsheet / pdf2png の追加セットアップは [`bin/README.md`](../bin/README.md) の「on Windows」節。
- VSCode のターミナルフォント `MesloLGS NF` は入れていなければ default に fallback する。

OS 設定は下記 Settings をそのままコピペし、エクスプローラーを再起動して反映する (開いているエクスプローラーのウィンドウは閉じる)。

```powershell
Stop-Process -Name explorer -Force
```

## Settings

### エクスプローラー: ナビゲーションウィンドウの「ホーム」「ギャラリー」を消す

- 目的: 左ペインを PC / ドライブ中心にする。ホーム (最近使ったファイル) とギャラリーは使わない。
- 適用日: 2026-10-01

```powershell
# ホーム
reg add "HKCU\Software\Classes\CLSID\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}" /v System.IsPinnedToNameSpaceTree /t REG_DWORD /d 0 /f
# ギャラリー
reg add "HKCU\Software\Classes\CLSID\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}" /v System.IsPinnedToNameSpaceTree /t REG_DWORD /d 0 /f
# ホームを消すので、エクスプローラーの起動先を「PC」にする (GUI: フォルダーオプション > 全般 > エクスプローラーで開く)
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v LaunchTo /t REG_DWORD /d 1 /f
```

戻し方:

```powershell
reg delete "HKCU\Software\Classes\CLSID\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}" /f
reg delete "HKCU\Software\Classes\CLSID\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}" /f
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v LaunchTo /f
```

### キーボード: CapsLock を左 Ctrl にする

- 目的: mac と同じく CapsLock を Ctrl として使う。terminal (bash の Ctrl 系) と VSCode の ctrl 系割り当てを mac と揃える。
- 適用日: 2026-10-01 (同日に一度 Alt にしたが、terminal 操作が揃わないので Ctrl に戻した)
- HKLM なので管理者 PowerShell で流す。反映は再起動 (サインアウトでは効かない)。

```powershell
# 0x3A (CapsLock) -> 0x1D (左 Ctrl)
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Keyboard Layout" /v "Scancode Map" /t REG_BINARY /d 0000000000000000020000001D003A0000000000 /f
```

戻し方:

```powershell
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Keyboard Layout" /v "Scancode Map" /f
```
