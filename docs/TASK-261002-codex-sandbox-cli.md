# TASK-261002: codex-sandbox-cli

261002 Codex sandbox で mise 管理 CLI を使う
===

## asis

- Windows の Codex sandbox で mise / node / npm / jq が見つからない。
- git / bash / codex は sandbox 内でも見つかる。
- sandbox 外では全部見つかる。

## tobe

- 新規 Codex sandbox で mise / node / npm / jq / git が動く。
- HOME と AppData の全体は開放しない。
- 全権限モードは使わない。
- チームは Windows 機ごとに一度だけ手順を流せばよい。

設計:

- sandbox ユーザーのグループに、CLI 用パスだけ読取権限を付ける。
- HOME と `~/.config` は一覧だけにする。中身のファイルは開けない。
- mise の dir は Codex の `shell_environment_policy.set` で渡す。
- global config の trust は、sandbox の外で一度だけ済ませる。
- ACL は変更前の DACL を保存し、その値で戻せるようにする。
- 手順は `windows/README.md` の Settings に置く。

## todo

- [x] `codex sandbox` で再現する
- [x] 原因を切り分ける
- [x] 変更前の ACL を保存してから、読取権限を付ける
- [x] Codex の config.toml をバックアップしてから、env を足す
- [x] 新規 sandbox セッションで検証する
- [x] `windows/README.md` にチーム向け手順を書く
- [x] ACL の保存と復元の手順を、テスト用フォルダで通す

## testcases

- [x] 新規 sandbox で mise / node / npm / jq / git の version が出る
- [x] `&&` で連結した確認コマンドが `exit=0` になる
- [x] `codex exec` の新規セッションでも同じ結果になる
- [x] sandbox から `~/.config` 配下の他ツールの設定は読めない
- [x] sandbox から `~/.ssh` は読めない
- [x] trust マーカーが無い state では、sandbox 内の mise が失敗する
- [x] state が読めない場合も、sandbox 内の mise が失敗する
- [x] 保存した DACL で戻すと、対象と子フォルダの ACL が元に戻る

## notes

確認環境は次のとおり。

- Windows 11 Home 26200、codex-cli 0.160.0、mise 2026.9.18。
- `windows.sandbox = "elevated"`、`sandbox_mode = "workspace-write"`。

確認環境での観察:

- sandbox は別ユーザーで動く。ユーザーは `CodexSandboxUsers` グループに入る。
- Codex は初回 setup で、HOME 直下の一部に読取権限を付ける。
- WinGet と mise のフォルダは継承が無効だった。その権限が届かなかった。
- permissions profile に read パスを足しても、ACE は付かなかった。
- ログには「read roots delegated」と出た。
- mise は config パスを canonicalize する。失敗すると config を無視する。
- canonicalize には、親フォルダの一覧権限が要った。
- mise は HOME を Windows API で取る。sandbox では `/` になった。
- HOME が `/` だと、global config の trust 先が `C:\` になった。
- `MISE_GLOBAL_CONFIG_ROOT` を HOME にすると、既存の trust マーカーと一致した。
- trust マーカーは、sandbox の外の `mise trust <global config>` で作れた。
- `icacls /restore` と `Set-Acl` は、特権不足で復元に失敗した。
- DACL だけを持つ `DirectorySecurity` で書き戻すと成功した。

調べ方:

- sandbox ログは `~/.codex/.sandbox/sandbox.YYYY-MM-DD.log` にある。
- `codex sandbox -- <cmd>` で、Codex を起動せずに sandbox を再現できる。
- sandbox 内の PowerShell は ConstrainedLanguage になる。メソッド呼び出しは使えない。
- `MISE_TRACE=1` を付けると、mise の config 読み込みを追える。

残課題:

- `~/.codex` 配下は、Codex 自身が sandbox に読取権限を付けている。
- 認証ファイルも sandbox から読める。今回の変更とは関係ない。
- winget で mise を更新すると、パッケージフォルダの ACL が変わる可能性がある。
- npm の global install と mise install は、sandbox 内では書き込めない。
