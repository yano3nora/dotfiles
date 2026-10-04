# Windows

## Overview

Windows はサブ機として、必要最低限の環境だけ用意する。mac の `dots` / zsh / Brewfile は持ち込まない。
shell は git bash、CLI は mise、GUI アプリは winget で入れる。設定ファイルは symlink せず `copy-configs.sh` でコピーする。
正は Windows 11 Home (10.0.26200) の実機。

Managed files:

- `README.md` - このメモ (セットアップ手順 + レジストリなどの OS 設定)
- `copy-configs.sh` - repo の設定ファイルを HOME / AppData にコピーする
- `bashrc` - git bash の設定。`~/.bashrc` には、これを source する 1 行だけを置く
- `gitconfig` - `~/.gitconfig`。`git/gitconfig` を include し、Windows で動かない設定だけ上書きする
- `vscode-settings.json` - `vscode/settings.json` に上書き merge する Windows 用の差分

OS 設定は項目ごとに「目的 / コマンド / 戻し方 / 適用日」を書く。GUI でしか設定できないものは GUI の場所を書く。
コマンドは PowerShell / cmd どちらでも流せる `reg.exe` で書く。HKCU のみなら管理者権限は不要。

## mac から持っていくもの

| 対象 | 扱い |
|---|---|
| `git/gitconfig`, `git/gitignore_global` | `windows/gitconfig` から include。`core.pager` の hunk だけ less に上書き (hunk は Windows で入らない) |
| `gh/config.yml` | そのままコピー |
| `git/hooks/pre-commit` | この repo の `.git/hooks/` にコピー。gitleaks は `mise/win.toml` で入る |
| `vscode/settings.json` | `windows/vscode-settings.json` を上書き merge して書き出す (フォントサイズ、既定ターミナルを Git Bash、Alt でメニューを開かない設定) |
| `vscode/keybindings.json` | mac cmd -> ctrl に読み替えて書き出す (mac ctrl はそのまま、CapsLock = Ctrl)。Windows 標準を優先したい ctrl+X (今は `f` `d` `i` `[` `]`) は mac 側の割り当てを alt+X に逃がす。`cmd+w` と `cmd+shift+i` は読み替えない。詳細は `copy-configs.sh` のコメント |
| `ai/CLAUDE.md` | `~/.claude/`, `~/.codex/` にコピー |
| `ai/skills/yano3nora/` (submodule) | `install.sh` で `~/.claude/skills/`, `~/.codex/skills/`, `~/.local/bin/` にコピー。配布先と同じ経路 |
| `bin/pdf2png` | `~/.local/bin/` にコピー (git bash で動く bash 製のものだけ) |
| `mise/mac.toml` | 共有しない。`mise/win.toml` に絞って別管理 |
| `Brewfile` の codex 経路 | mac と同じく公式 installer で入れる。手順は Getting Started の 6 |
| `lazygit/config.yml` | 持っていかない。hunk と coda 前提。default で使う |
| `ai/local/chrome-connect`, zsh 製の `bin/*` | 持っていかない。zsh 前提 |
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
git submodule update --init ai/skills/yano3nora   # zsh plugin は要らないので全部は取らない
# 3. 設定ファイルをコピー (既存は .bak.YYYYMMDDHHMMSS に退避)
./windows/copy-configs.sh
# 4. CLI
mise install   # 403 (rate limit) なら GITHUB_TOKEN="$(gh auth token)" mise install
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
- gsheet の追加セットアップ (鍵 JSON、PATH) は `ai/skills/yano3nora/skills/gsheet/README.md`。pdf2png は [`bin/README.md`](../bin/README.md) の「on Windows」節。
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

### Codex sandbox: mise 管理 CLI を使えるようにする

- 目的: Codex sandbox 内で mise 管理の CLI を使う。
- 適用日: 2026-10-02
- 確認環境: Windows 11 Home 26200、codex-cli 0.160.0、mise 2026.9.18。
- 前提: Getting Started の 1-6 を済ませていること。
- 前提: Codex を一度起動し、sandbox を作っていること。
- 前提: mise は winget で入れていること。

確認環境での観察:

- sandbox は別ユーザーで動く。ユーザーは `CodexSandboxUsers` グループに入る。
- WinGet と mise のフォルダは継承が無効だった。sandbox から読めなかった。
- permissions profile の read 指定では、ACE は付かなかった。
- mise は config パスを canonicalize する。失敗すると config を無視する。
- canonicalize には、親フォルダの一覧権限が要った。
- sandbox ユーザーには profile が無い。mise の HOME が `/` になった。
- このため mise の dir を env で渡す。
- trust マーカーが無いと、mise は sandbox 内で書き込もうとして失敗した。
- state フォルダが読めない場合も、mise は失敗した。

1\. sandbox の外で、global config を trust する。

```powershell
mise trust "$env:USERPROFILE\.config\mise\config.toml"
```

2\. 変更前の ACL を保存し、`CodexSandboxUsers` に読取権限を付ける。

- HOME と `~/.config` は一覧だけにする。中身のファイルは開けない。
- 保存先の `acl.tsv` は戻し方で使う。保存先のパスを控えておく。
- 対象パスが 1 つでも無ければ、何も変えずに止まる。
- 保存が 1 件でも失敗すれば、権限を変えずに止まる。
- icacls が失敗した時点で止まる。

```powershell
& {
  $ErrorActionPreference = 'Stop'
  $g = 'CodexSandboxUsers'
  $bak = "$env:USERPROFILE\Documents\codex-sandbox-acl-$(Get-Date -Format yyyyMMddHHmmss)"
  # 中身まで読める。子フォルダに継承する
  $inherit = @(
    "$env:LOCALAPPDATA\Microsoft\WinGet\Links",
    "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\jdx.mise_Microsoft.Winget.Source_8wekyb3d8bbwe",
    "$env:LOCALAPPDATA\mise\shims",
    "$env:LOCALAPPDATA\mise\installs",
    "$env:LOCALAPPDATA\mise\migrations",
    "$env:USERPROFILE\.config\mise",
    "$env:USERPROFILE\.local\state\mise")
  # 一覧だけ。子フォルダに継承しない
  $listOnly = @($env:USERPROFILE, "$env:USERPROFILE\.config")
  $missing = @($inherit + $listOnly | Where-Object { -not (Test-Path $_) })
  if ($missing) { throw "見つからない: $missing" }
  New-Item -ItemType Directory $bak | Out-Null
  foreach ($p in $inherit + $listOnly) {
    "$p`t$((Get-Acl $p).GetSecurityDescriptorSddlForm('Access'))" | Add-Content -Encoding utf8 "$bak\acl.tsv"
  }
  # ここまでで保存が全件終わっている。理由: 失敗時は Stop で抜ける
  foreach ($p in $inherit) {
    icacls $p /grant "${g}:(OI)(CI)RX"
    if ($LASTEXITCODE -ne 0) { throw "icacls 失敗: $p" }
  }
  foreach ($p in $listOnly) {
    icacls $p /grant "${g}:(RX)"
    if ($LASTEXITCODE -ne 0) { throw "icacls 失敗: $p" }
  }
  "保存先: $bak"
}
```

3\. `~/.codex/config.toml` をバックアップする。

```powershell
Copy-Item "$env:USERPROFILE\.codex\config.toml" "$env:USERPROFILE\.codex\config.toml.bak.$(Get-Date -Format yyyyMMddHHmmss)"
Select-String -Path "$env:USERPROFILE\.codex\config.toml" -Pattern '^\s*\[shell_environment_policy\.set\]', '^\s*set\s*='
```

4\. config.toml に次の 3 キーを書く。

- `<user>` は自分のユーザー名に書き換える。
- 3 で何も出なければ、下の表を末尾に追記する。
- 親表 `[shell_environment_policy]` だけがある場合も、末尾に追記する。
- `[shell_environment_policy.set]` が出た場合は、表を追記しない。
- その場合は、その表の中で 3 キーを更新する。無いキーだけ足す。
- 親表の中に `set = ` が出た場合も、表を追記しない。
- その場合は、その `set` の中で 3 キーを更新する。
- 同じキーを二重に書かない。理由: 重複すると config が読めなくなる。

```toml
[shell_environment_policy.set]
MISE_CONFIG_DIR = 'C:\Users\<user>\.config\mise'
MISE_STATE_DIR = 'C:\Users\<user>\.local\state\mise'
MISE_GLOBAL_CONFIG_ROOT = 'C:\Users\<user>'
```

確認: 全部の version が出て、`exit=0` になること。

```powershell
codex sandbox -- cmd /c "mise --version && node --version && npm --version && jq --version && git --version"; "exit=$LASTEXITCODE"
```

戻し方: 保存した ACL を書き戻す。子フォルダの継承も戻る。

```powershell
& {
  $bak = '<保存先>'
  foreach ($line in Get-Content -Encoding utf8 "$bak\acl.tsv") {
    $p, $sddl = $line -split "`t"
    $a = New-Object System.Security.AccessControl.DirectorySecurity
    $a.SetSecurityDescriptorSddlForm($sddl, 'Access')
    (Get-Item $p).SetAccessControl($a)
  }
}
```

- config.toml は、3 で作ったバックアップに戻す。
- `icacls /restore` と `Set-Acl` は使わない。理由: 確認環境では特権不足で失敗した。
