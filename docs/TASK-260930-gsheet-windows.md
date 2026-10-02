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
- `bin/gsheet.cmd` を足す。PowerShell / cmd から `bash.exe -l` で `gsheet` を呼ぶ 2 行の shim
    - 理由: Codex は Windows では PowerShell でコマンドを実行する (codex-rs/shell-command/src/shell_detect.rs)。config で変えられない
    - 644 で置く。理由: `dots link` は executable だけ `~/.local/bin` に張るので、mac 側に影響しない
- values / body に `@<file>` 読み込みを足す。理由: PowerShell → cmd → bash の経路で JSON 引数の引用符が壊れる。UTF-8 BOM は除く
- `bin/README.md` に「gsheet on Windows (git bash)」節を足す。`pdf2png on Windows` と同じ体裁
- サービスアカウントの鍵 JSON で動く経路を足す。`GOOGLE_APPLICATION_CREDENTIALS` があれば openssl で JWT を署名し、token endpoint で access token に交換する
    - 理由: 社内デモで複数人に配るとき、各自の Google アカウントと IAM 追加、gcloud のインストールとログインが要らなくなる
    - `domain:` の IAM は使えなかった。理由: 社のドメインは Google Workspace / Cloud Identity に登録されていない
    - gcloud の `print-access-token` は SA に Sheets の scope を付けられない。ADC 経由なら `--scopes` が使えるが、gcloud 自体を無くす方を選んだ
    - quota header は SA では送らない。理由: 割り当て先は鍵の project に決まり、header を送ると SA にも IAM が要る
    - 秘密鍵は 600 の一時ファイルで openssl に渡し、署名後に消す。理由: git bash の openssl は native 版で、プロセス置換の /dev/fd を読めない。token は cache しない
    - JWT は stdin で curl に渡す。理由: プロセス引数は他のプロセスから見える。Bearer header は従来どおり引数で、1 時間で切れる token なので許容する

## todo

- [x] `bin/gsheet` を bash 3.2 へ移植
- [x] `bin/README.md` に Windows 手順と一覧行の更新
- [x] `bin/gsheet.cmd` と `@<file>` の追加、`ai/skills/gsheet/SKILL.md` に Windows の注意を追加
- [x] サービスアカウント経路の追加、`bin/README.md` に「gsheet with a service account」節を追加
- [x] 偽 gcloud / curl で mac の `/bin/bash` 3.2 上の全コマンドを確認
- [x] `bash -n bin/gsheet` / `dots doctor`
- [x] Codex にレビュー依頼 (P2 1 件を反映。notes 参照)
- [x] 人間: Windows 実機で `gsheet meta` を確認 (2026-10-02)。gcloud は SA 経路化で不要になった

## testcases

- [x] macOS `/bin/bash` 3.2 で `meta` / `get` / `set` / `append` / `api` の request が zsh 版と同じになる
- [x] gcloud の出力に `\r` が付いても header に混ざらない
- [x] macOS で `jq -b` が従来と同じ出力を返す
- [x] 空白だけの values、2 次元配列でない values は 1 行のエラーで非 0 終了する
- [x] `@<file>` で BOM 付き UTF-8 の日本語 JSON を読み、request body が正しい。無いファイルは 1 行のエラーで非 0 終了する
- [x] project 未設定、資格情報なしは手順を表示して非 0 終了する
- [x] SA 経路: 生成した RSA 鍵で JWT を作り、公開鍵で署名を検証できる。claims は iss / scope / aud / iat / exp
- [x] SA 経路: 本物の token endpoint が JWT を受理し、存在しない SA は `invalid_grant: account not found` を返す
- [x] SA 経路: gcloud が PATH に無くても `meta` の request が組める。`x-goog-user-project` header を送らない
- [x] SA 経路: `type` が service_account でない JSON、無い JSON は 1 行のエラーで非 0 終了する
- [x] gcloud 経路: header と token が従来どおり付く
- [x] SA 経路: 本物の鍵と SA に共有したスプシで `meta` が 200 を返す (2026-09-30 macOS)。未共有だと Sheets API が 403 `PERMISSION_DENIED` を返す
- [x] Windows git bash で `gcloud` が `command -v` で見つかる → SA 経路化で不要になった
- [x] Windows git bash で `gsheet meta <url>` が 200 を返す (2026-10-02)
- [x] Windows PowerShell で `gsheet meta <id>` が 200 を返し、`@<file>` の日本語が文字化けせず書ける (2026-10-02)

## notes

- Codex レビュー 3 回目 (2026-09-30、SA 経路) の指摘と対応
    - P2: SA 経路の jq にも `-b` が要る。iss と token に CR が混ざる。全 jq に付けた
    - P2: git bash の `openssl` は `/mingw64/bin` の native 版が先に解決され、プロセス置換の `/dev/fd` を読めない。600 の一時ファイルに変えた
    - P2: JWT がプロセス引数に露出する。`--data-urlencode 'assertion@-'` で stdin 渡しにした
    - P3: README の「jq は git bash に入っている」は誤り。mise 導入に直した
- Codex レビュー 2 回目 (2026-09-30、shim と @file) の指摘と対応
    - P2: README の PATH 設定を bash から `powershell -Command "..."` で呼ぶと `$env` が bash に展開される。PowerShell で直接実行する手順に変えた
    - P2: PowerShell では先頭の `@` が splatting 構文。SKILL / README の例を `'@C:\...'` に変えた
        - https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_parsing
    - P2: `bash -l` は HOME へ cd するので相対 `@file` が壊れる。shim で `CHERE_INVOKING=1` を立てた
    - P2: cmd は `&` を区切りと解釈し、URL の `&usp=` 以降がコマンドになる。SKILL で「Windows では ID を渡す、`&` を入れない」とした。cmd を介さない `.ps1` は実行ポリシーに依存するので採らない
- Codex レビュー (2026-09-30) の指摘と対応
    - P2: Windows 版 jq は標準で CRLF を出力し、`range` の URL 末尾に CR が残る。`uri_encode` に `jq -b` を付けた
        - https://jqlang.org/manual/#invoking-jq
- 未検証: git bash で `gcloud` が拡張子なしで解決するか。SDK の `bin/` には `gcloud` と `gcloud.cmd` の両方がある想定。見つからなければ PATH 追加か wrapper が要る
- token の使い回しはしない。access token は 1 時間で切れ、使い回せるのは refresh token だけ。それは配るものではない
- 他人に配る場合は追加対応が要る。quota project の権限 (`serviceusage.serviceUsageConsumer`) か、各自で project を作る
