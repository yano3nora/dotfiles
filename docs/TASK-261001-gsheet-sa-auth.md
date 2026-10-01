# TASK-261001: `gsheet` の認証をサービスアカウントの鍵 JSON だけにする

261001 `gsheet` の認証をサービスアカウントの鍵 JSON だけにする
===

## asis

- `bin/gsheet` の認証は 2 経路。`GOOGLE_APPLICATION_CREDENTIALS` があれば鍵 JSON、無ければ gcloud の資格情報
- `bin/README.md` と SKILL.md は gcloud 経路を先に書き、鍵 JSON 経路は補足扱い
- 環境変数が無いときのエラー文は「gcloud が無い」で、鍵 JSON の存在を示さない
- 結果: 初見の Codex が Windows で `gsheet` を使うとき、鍵 JSON の環境変数を人間が教えるまで気づけなかった

## tobe

- 認証はサービスアカウントの鍵 JSON だけ。gcloud の実行時経路は削除する
    - 理由: 経路が 1 つなら Agent は分岐せず、エラー文も手順を 1 つだけ示せる
    - 理由: 鍵 JSON 経路は macOS / Windows の両方で動き、scope が `spreadsheets` だけで済む
- 鍵の置き場は固定パス `~/.config/gsheet/key.json`。環境変数の設定は要らない
    - 理由: git bash の `$HOME` は `%USERPROFILE%` なので、Windows の Codex も PowerShell 経由で読める
    - 理由: `GOOGLE_APPLICATION_CREDENTIALS` は他の Google SDK も読む。shell 全体に立てると副作用が出る
- `GOOGLE_APPLICATION_CREDENTIALS` は別の鍵を一時的に使う上書きとしてだけ残す。コードは 1 行で済む
- 鍵が無いとき、`gsheet` は「鍵 JSON が無い: <既定パス>。そこに置く」と 1 行で止まる。環境変数で上書き中なら「変数が指す鍵を読めない」と出し、既定パスへの配置は案内しない
- SKILL.md の先頭に認証の節を置く。鍵が無ければユーザに配置を依頼し、gcloud の導入や鍵の探索・作成をしないと書く
- gcloud は鍵を作るときだけ使う。Brewfile には残し、`dots doctor` の必須コマンドからは外す

## トレードオフ

- spreadsheet ごとに鍵の `client_email` へ共有が要る。gcloud 経路なら自分が開けるものは全部触れた
- 編集履歴はサービスアカウント名になる。誰が書いたかは区別できない

## todo

- [x] `bin/gsheet` から gcloud 経路と quota header の分岐を削除
- [x] `bin/gsheet` の鍵を固定パス既定にし、環境変数は上書きだけにする
- [x] `ai/skills/gsheet/SKILL.md` に認証の節を追加し、sandbox 除外の理由を通信拒否に変更
- [x] `bin/README.md` の gsheet 節を固定パス前提に書き直し。Windows 節から gcloud と環境変数の手順を削除
- [x] `ai/README.md` の excludedCommands の理由を通信拒否に変更
- [x] `bin/dots` の doctor から gcloud を削除、Brewfile のコメントを鍵作成用に変更
- [x] `bash -n bin/gsheet` / `zsh -n bin/dots` / `dots doctor`
- [x] Codex にレビュー依頼
- [ ] 人間: Windows の `%USERPROFILE%\.config\gsheet\key.json` に鍵を置き、PowerShell から `gsheet meta` を確認

## testcases

- [x] 鍵なし: 「鍵 JSON が無い: <既定パス>」と置き場を 1 行で出し、非 0 終了する。gcloud の有無は見ず、`set` で JSON を省略しても stdin を待たない
- [x] 環境変数が読めないパス: 「GOOGLE_APPLICATION_CREDENTIALS が指す鍵 JSON を読めない: <そのパス>」を 1 行で出し、非 0 終了する
- [x] 既定パスの鍵で環境変数なしに token が取れる。環境変数があればそちらを優先する
- [x] 使い捨ての RSA 鍵で `meta` を呼ぶと、token endpoint が `invalid_grant` を返す。JWT の組み立てと通信が通る
- [x] 偽 curl で `set` の request を見ると、`Authorization` はあり `x-goog-user-project` は無い
- [x] Claude Code の sandbox 内では `oauth2.googleapis.com` が拒否される。`excludedCommands` の除外は引き続き要る
- [ ] Windows: git bash の `~/.config/gsheet/key.json` が `%USERPROFILE%` 配下に解決され、PowerShell 経由でも読める

## notes

- 鍵 JSON は 2026-09-30 に作成済みで、この Mac の `~/.config/gsheet/key.json` にある。SA 名は `claude`
- Codex レビュー (2026-10-01) の指摘と対応
    - P2: `set` で JSON を省略すると、鍵が無くても stdin 待ちになる。`require_auth` を各コマンドの入力処理より前に移した
    - P2: README の確認コマンドが共有手順より先で、新規 SA では必ず失敗する。共有を先にした
    - P3: 鍵のパスの置き場が README と作業記録で矛盾していた。固定パス既定にして export 自体を無くした
- Codex レビュー 2 回目 (2026-10-01、固定パス化) の指摘と対応
    - P2: 既定パスに `XDG_CONFIG_HOME` を混ぜると README の置き場と食い違う。`$HOME/.config` 固定にした
    - P2: 環境変数が不正パスでも既定パスへの配置を案内していた。置いても変数が優先されるので、変数を直す案内に分けた
    - P2: Windows 手順から PATH 設定後のシェル再起動が消えていた。戻した
