# TASK-261001: `gsheet` の認証をサービスアカウントの鍵 JSON だけにする

261001 `gsheet` の認証をサービスアカウントの鍵 JSON だけにする
===

## asis

- `bin/gsheet` の認証は 2 経路。`GOOGLE_APPLICATION_CREDENTIALS` があれば鍵 JSON、無ければ gcloud の資格情報
- `bin/README.md` と SKILL.md は gcloud 経路を先に書き、鍵 JSON 経路は補足扱い
- 環境変数が無いときのエラー文は「gcloud が無い」で、鍵 JSON の存在を示さない
- 結果: 初見の Codex が Windows で `gsheet` を使うとき、鍵 JSON の環境変数を人間が教えるまで気づけなかった

## tobe

- 認証は `GOOGLE_APPLICATION_CREDENTIALS` の鍵 JSON だけ。gcloud の実行時経路は削除する
    - 理由: 経路が 1 つなら Agent は分岐せず、エラー文も設定手順を 1 つだけ示せる
    - 理由: 鍵 JSON 経路は macOS / Windows の両方で動き、scope が `spreadsheets` だけで済む
- 環境変数が無いとき、`gsheet` は「GOOGLE_APPLICATION_CREDENTIALS が未設定。鍵 JSON のパスを設定する」と 1 行で止まる
- SKILL.md の先頭に認証の節を置く。未設定ならユーザに設定を依頼し、gcloud の導入や鍵の探索をしないと書く
- gcloud は鍵を作るときだけ使う。Brewfile には残し、`dots doctor` の必須コマンドからは外す

## トレードオフ

- spreadsheet ごとに鍵の `client_email` へ共有が要る。gcloud 経路なら自分が開けるものは全部触れた
- 編集履歴はサービスアカウント名になる。誰が書いたかは区別できない
- `GOOGLE_APPLICATION_CREDENTIALS` は他の Google SDK も読む。shell 全体に設定するとそれらもこの鍵を使う

## todo

- [x] `bin/gsheet` から gcloud 経路と quota header の分岐を削除
- [x] `ai/skills/gsheet/SKILL.md` に認証の節を追加し、sandbox 除外の理由を通信拒否に変更
- [x] `bin/README.md` の gsheet 節を鍵 JSON 前提に書き直し
- [x] `ai/README.md` の excludedCommands の理由を通信拒否に変更
- [x] `bin/dots` の doctor から gcloud を削除、Brewfile のコメントを鍵作成用に変更
- [x] `bash -n bin/gsheet` / `zsh -n bin/dots` / `dots doctor`
- [x] Codex にレビュー依頼
- [ ] 人間: Mac の `~/.zshenv` に `GOOGLE_APPLICATION_CREDENTIALS` を設定し、`gsheet meta` を確認
- [ ] 人間: Windows のユーザ環境変数に設定し、PowerShell から `gsheet meta` を確認

## testcases

- [x] 環境変数なし: 「GOOGLE_APPLICATION_CREDENTIALS が未設定」を 1 行で出し、非 0 終了する。gcloud の有無は見ず、`set` で JSON を省略しても stdin を待たない
- [x] 環境変数が読めないパス: 「鍵 JSON を読めない」を 1 行で出し、非 0 終了する
- [x] 使い捨ての RSA 鍵で `meta` を呼ぶと、token endpoint が `invalid_grant` を返す。JWT の組み立てと通信が通る
- [x] 偽 curl で `set` の request を見ると、`Authorization` はあり `x-goog-user-project` は無い
- [x] Claude Code の sandbox 内では `oauth2.googleapis.com` が拒否される。`excludedCommands` の除外は引き続き要る
- [ ] Windows: `GOOGLE_APPLICATION_CREDENTIALS` が `C:\...` 形式でも git bash の `gsheet` が鍵を読める

## notes

- 鍵の置き場は `~/.config/gsheet/key.json` を README の例にした。export は repo 管理外の `~/.zshenv` に書く。理由: 鍵が無い機でも dotfiles は共通で、環境変数だけ立つと他の Google SDK が落ちる
- Codex レビュー (2026-10-01) の指摘と対応
    - P2: `set` で JSON を省略すると、未設定でも stdin 待ちになる。`require_auth` を各コマンドの入力処理より前に移した
    - P2: README の確認コマンドが共有手順より先で、新規 SA では必ず失敗する。共有を先にした
    - P3: export の置き場が README と作業記録で矛盾していた。`~/.zshenv` に統一した
