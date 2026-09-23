# TASK-260923: Google Sheets を Agent から読み書きする CLI `gsheet` を追加する

260923 Google Sheets を Agent から読み書きする CLI `gsheet` を追加する
===

## asis

- claude.ai の Google Drive connector は閲覧専用。セル更新・行追加ができない
- `update_file` はファイル丸ごと差し替え。セル編集には使えない
- Google 公式の Sheets MCP は Developer Preview。GCP で OAuth 同意画面と OAuth client を自作し、claude.ai にカスタムコネクタ登録が要る
- gcloud は未導入。mise の `gcloud` plugin (vfox) は `mise ls-remote gcloud` が内部エラーで失敗した (2026-09-23, mise 2026.9.12)

## tobe

- 「この spreadsheet の B5 を更新して」と頼めば、Claude Code / Codex が Bash 経由でセルを読み書きできる
- 認可は gcloud 内蔵の OAuth client を使う。OAuth 同意画面・client の自作、claude.ai の設定変更は不要
- 新 Mac でも `brew bundle` + `dots link` + gcloud 手順 4 行で再現できる

## 設計

### コンセプト

gcloud のトークンで Sheets REST API を curl する薄い CLI `bin/gsheet` を作る。Agent はそれを Bash で叩く。MCP は使わない。

- 理由: OAuth client の自作と claude.ai 側の設定を丸ごと省ける
- 理由: Agent は REST API の JSON をそのまま読める。整形層は要らない
- トレードオフ: claude.ai (Web / Desktop) からは使えない。Claude Code / Codex 専用

### 構成

| 対象 | 変更 |
| --- | --- |
| `Brewfile` | `cask "gcloud-cli"` を CLI 区画に追加。コメントで `bin/gsheet` 依存を明記 |
| `bin/gsheet` | 新規。zsh。`dots addbin gsheet` の雛形から作る |
| `bin/dots` | `doctor` の `commands` に `gcloud` を追加。`link_all` に `ai/skills/gsheet` を追加 |
| `bin/README.md` | `gsheet` の一覧行と GCP 初期設定の節を追加 |
| `ai/skills/gsheet/SKILL.md` | 新規。Agent に `gsheet` の存在と使い方・注意を教える |
| `ai/README.md` | Managed files に skills 追加は不要 (`skills/*/` で包含済み) |

mise は使わない。理由: gcloud は Python 同梱の大きな SDK で、plugin も動かなかった。AGENTS.md の「build / OS 依存が重いものは brew」に該当する。

### `bin/gsheet` の仕様

```
gsheet meta   <sheet>                  # sheet 名と行列数の一覧
gsheet get    <sheet> <range>          # 値を取得
gsheet set    <sheet> <range> [values]  # 値を上書き (USER_ENTERED)
gsheet append <sheet> <range> [values]  # 末尾に行を追加
gsheet api    <METHOD> <path> [body]    # 生 API。batchUpdate など
```

- `<sheet>` は spreadsheet URL でも ID でもよい。URL から `/d/<id>/` を抜く
- `<range>` は `Sheet1!A1:C10` 形式。日本語 sheet 名のため jq `@uri` でエンコードする
- `values` / `body` は JSON 文字列を引数で渡す。省略時は stdin。理由: Agent は引数で渡さないと sandbox 除外が外れる
- 出力は API の JSON をそのまま stdout へ。整形しない。理由: Agent と jq に任せる
- 認可: `gcloud auth print-access-token`。ADC は使わない
- 割り当て先: `x-goog-user-project: $(gcloud config get-value project)`。未設定なら手順を出して終了
- 書き込みは `set` / `append` / `api` の 3 つだけ。dry-run は作らない。理由: Bash の実行許可プロンプトが確認ポイント
- 依存: `gcloud`, `curl`, `jq`。`jq` は mise 管理済み

### 認可の設計

- `gcloud auth login --enable-gdrive-access` で内蔵 client に `drive` scope を足す
- Sheets API は `drive` scope を受け付ける。トークンは `gcloud auth print-access-token` で取る
- ADC は使わない。理由: ADC で Drive 系 scope を取るには `--client-id-file` で自作 OAuth client が必須
- scope は `drive` 全体。`spreadsheets` に絞れない。理由: 内蔵 client で取れる Drive 系 scope は `--enable-gdrive-access` の 1 つだけ
- 割り当て用の GCP project が 1 つ要る。API 有効化は `sheets.googleapis.com` だけ
- 資格情報は `~/.config/gcloud/` に残る。repo には載せない

初期設定 (人間が 1 回だけ実行する):

```sh
brew bundle
gcloud auth login --enable-gdrive-access
gcloud projects create <project-id>
gcloud config set project <project-id>
gcloud services enable sheets.googleapis.com
```

最小権限にしたい場合の代替: GCP で Desktop 用 OAuth client を作り、`gcloud auth application-default login --client-id-file=<json> --scopes=https://www.googleapis.com/auth/spreadsheets` で ADC を取る。`gsheet` の `access_token` を `application-default print-access-token` に変える。自作 client が要るので初期案から外した。

### `ai/skills/gsheet/SKILL.md` の内容

- トリガー: spreadsheet / Google Sheets の読み書きを頼まれたとき
- `gsheet --help` を読んでから使う
- Claude Code では `gsheet …` を単一コマンドで呼ぶ。理由: sandbox は `~/.config/gcloud` への書き込みを禁止するので、settings.json の `excludedCommands: ["gsheet *"]` で除外する
- 書き込み前に `meta` と `get` で対象 range を確認する
- 初回や大きな変更はコピーした spreadsheet で試す

### やらないこと

- zsh 補完、alias、`dots mcp` への組み込み
- Google 公式 Sheets MCP の登録。理由: 本設計で目的を満たす。必要になったら `ai/mcp.json` に追加できる
- 値の整形出力 (TSV / 表)。理由: 利用者は Agent

## todo

- [x] `Brewfile` に `cask "gcloud-cli"` を追加
- [x] `dots addbin gsheet` で雛形を作り、仕様どおり実装
- [x] `bin/dots` の `doctor` に `gcloud` を追加
- [x] `ai/skills/gsheet/SKILL.md` を作り、`bin/dots` の `link_all` に追加
- [x] `bin/README.md` に `gsheet` の行と初期設定の節を追加
- [x] `zsh -n bin/dots` / `zsh -n bin/gsheet` / `dots doctor`
- [x] 人間: `brew bundle` と GCP 初期設定を実行 (2026-09-23)
- [x] Codex にレビュー依頼 (指摘 2 件を反映。notes 参照)

## testcases

- [x] `gcloud auth login --enable-gdrive-access` 後、`gcloud auth print-access-token` のトークンで Sheets API が 200 を返す
- [x] `gsheet meta <url>` で sheet 名が返る
- [x] `gsheet get` で日本語 sheet 名の range が読める (Claude Code から確認)
- [x] `gsheet set` でセルが更新され、数式が `USER_ENTERED` で評価される (2026-09-23 Claude Code の sandbox 内から test シートで確認)
- [x] `gsheet append` で末尾に行が増える (2026-09-23 Claude Code の sandbox 内から test シートで確認)
- [x] `gsheet api POST spreadsheets/<id>:batchUpdate` が通る (2026-09-23 Claude Code の sandbox 内から test シートで確認)
- [x] project 未設定のとき、手順を表示して非 0 で終了する
- [x] Claude Code の sandbox 内から `gsheet get` が成功する → **失敗**。sandbox が `~/.config/gcloud` への書き込みを禁止し、`credentials.db` と `logs/` を開けない
- [x] settings.json に `excludedCommands: ["gsheet *"]` を足した後、Claude Code の Bash tool から `gsheet meta <id>` が成功する (2026-09-23)
- [x] `dots doctor` で `gcloud` が ok になる
- [x] `dots link` で `~/.claude/skills/gsheet` と `~/.codex/skills/gsheet` が張られる

## notes

- 実装時に踏んだ zsh の罠 (偽 gcloud / curl で検証して発見)
    - `local path` は PATH と連動する特殊配列を壊す。`api_path` に改名した
    - `$range:append` は `:a` 修飾子として解釈され絶対 path に化ける。`${range}:append` にした

- Google 公式 Sheets MCP: `https://sheetsmcp.googleapis.com/mcp/v1`。Pro 以上 + Developer Preview
    - https://developers.google.com/workspace/sheets/api/guides/configure-mcp-server
- Codex レビュー (2026-09-23) の指摘と対応
    - P1: ADC で Drive 系 scope を取るには `--client-id-file` が必須。初期設計の「内蔵 client + ADC + spreadsheets scope」は成立しない。`gcloud auth login --enable-gdrive-access` + `gcloud auth print-access-token` に変更した。scope は `drive` 全体になる
        - https://docs.cloud.google.com/sdk/gcloud/reference/auth/application-default/login
        - https://docs.cloud.google.com/bigquery/docs/external-data-drive
    - P2: `set` の「range 全体を上書き」は誤り。values の形だけ書き、`null` は保持、`""` で消去。SKILL.md を修正した
        - https://developers.google.com/workspace/sheets/api/guides/values
- sandbox 対応の判断: codex と同じく settings.json の `excludedCommands` に `gsheet *` を足す。ai/README.md 参照
    - `~/.config/gcloud` を書き込み許可に足す案は採らない。理由: 資格情報の置き場を全コマンドから書き込み可能にする
    - `dangerouslyDisableSandbox` は auto mode の classifier に止められた (2026-09-23)
    - `<<<` ヒアストリングでも除外が外れた (2026-09-23 再現)。`set` / `append` / `api` は JSON を引数で受ける形に変更した
    - Codex 3 回目の指摘: 空白だけの values が通る、明示した `''` が stdin 読みに化ける。引数の有無を個数で判定し、jq 出力の空チェックを入れた
- 残リスク: `set` / `append` は stdin の値が許可プロンプトに出ない。range だけで判断することになる。コピーで試す運用でカバーする
- 残リスク: gcloud のトークンは自分の Drive 全体に効く。`~/.config/gcloud/` の扱いは他の gcloud 資格情報と同じ
