# TASK-260930: `gsheet` を Windows の git bash でも動かす

260930 `gsheet` を Windows の git bash でも動かす
===

## asis

- `bin/gsheet` は zsh 製。git bash に zsh は無い
- Windows 側の前提: WSL2 なし、git bash と mise あり
- 資格情報は Mac の `~/.config/gcloud/` にだけある

## tobe

- `bin/gsheet` 1 本で macOS の `/bin/bash` 3.2 と git bash の両方で動く。`pdf2png` と同じ流儀
- 資格情報は Windows で `gcloud auth login --enable-gdrive-access` し直す。Mac からコピーしない
    - 理由: refresh token は自分の Drive 全体に効く
- GCP project は Mac と同じものを `gcloud config set project` で指す。作成と API 有効化は不要

## 設計

- shebang を `bash` にし、bash 3.2 で動く構文だけ使う
    - `match[1]` → `BASH_REMATCH[1]`。正規表現は変数に置く。理由: bash は引用符付きの右辺を文字列一致にする
    - `${1:u}` → `tr '[:lower:]' '[:upper:]'`。理由: `${1^^}` は bash 4 以降
    - 空配列の展開は `${arr[@]+"${arr[@]}"}`。理由: bash 3.2 は `set -u` で空配列を unbound と扱う
    - `$(...)` の中で `die` する箇所には `|| exit 1` を付ける。理由: bash 3.2 は `inherit_errexit` が無く、`die` が subshell しか終了させない
- `uri_encode` の jq に `-b` を付ける。理由: Windows 版 jq は CRLF を出し、`$(...)` は LF しか除かない
- gcloud の出力を `tr -d '\r'` に通す。理由: git bash では `.cmd` 経由の出力に CR が混ざり、curl の header で落ちる
- `bin/README.md` に「gsheet on Windows (git bash)」節を足す。`pdf2png on Windows` と同じ体裁

## todo

- [x] `bin/gsheet` を bash 3.2 へ移植
- [x] `bin/README.md` に Windows 手順と一覧行の更新
- [x] 偽 gcloud / curl で mac の `/bin/bash` 3.2 上の全コマンドを確認
- [x] `bash -n bin/gsheet` / `dots doctor`
- [x] Codex にレビュー依頼 (P2 1 件を反映。notes 参照)
- [ ] 人間: Windows 実機で `gcloud --version` と `gsheet meta` を確認

## testcases

- [x] macOS `/bin/bash` 3.2 で `meta` / `get` / `set` / `append` / `api` の request が zsh 版と同じになる
- [x] gcloud の出力に `\r` が付いても header に混ざらない
- [x] macOS で `jq -b` が従来と同じ出力を返す
- [x] 空白だけの values、2 次元配列でない values は 1 行のエラーで非 0 終了する
- [x] project 未設定、資格情報なしは手順を表示して非 0 終了する
- [ ] Windows git bash で `gcloud` が `command -v` で見つかる
- [ ] Windows git bash で `gsheet meta <url>` が 200 を返す

## notes

- Codex レビュー (2026-09-30) の指摘と対応
    - P2: Windows 版 jq は標準で CRLF を出力し、`range` の URL 末尾に CR が残る。`uri_encode` に `jq -b` を付けた
        - https://jqlang.org/manual/#invoking-jq
- 未検証: git bash で `gcloud` が拡張子なしで解決するか。SDK の `bin/` には `gcloud` と `gcloud.cmd` の両方がある想定。見つからなければ PATH 追加か wrapper が要る
- token の使い回しはしない。access token は 1 時間で切れ、使い回せるのは refresh token だけ。それは配るものではない
- 他人に配る場合は追加対応が要る。quota project の権限 (`serviceusage.serviceUsageConsumer`) か、各自で project を作る
