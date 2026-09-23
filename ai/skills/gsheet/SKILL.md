---
name: gsheet
description: Google Sheets (spreadsheet) のセルを読み書きする。「この spreadsheet を読んで / 更新して / 行を足して」と言われたら、Google Drive connector ではなく bin/gsheet を Bash で使う。
---

# gsheet

Google Drive connector は閲覧専用で、セル更新ができない。`gsheet` は gcloud の認可で Sheets REST API を直接叩く CLI。

## 使い方

`gsheet --help` を読んでから使う。出力は Sheets API の JSON そのまま。jq で整形する。

```bash
gsheet meta   <url|id>                       # sheet 名と行列数
gsheet get    <url|id> 'Sheet1!A1:C10'       # 値を取得
gsheet set    <url|id> 'Sheet1!B5' '[["Completed"]]'
gsheet append <url|id> 'Sheet1!A:C' '[["a","b","c"]]'
gsheet api    POST spreadsheets/<id>:batchUpdate '{"requests":[...]}'
```

## 手順

1. 書き込み前に `meta` と `get` で対象の sheet 名と range を確認する
2. 数式は `=SUM(A1:A3)` の文字列で渡す。`USER_ENTERED` で評価される
3. 初回や大きな変更は、ユーザにコピーした spreadsheet で試すことを提案する

## 注意

- Claude Code では `gsheet …` を単一コマンドとして Bash tool で呼ぶ。`cd` / パイプ / `&&` / リダイレクトで包まない
    - 理由: sandbox は `~/.config/gcloud` への書き込みを禁止し、gcloud が動かない。settings.json の `excludedCommands: ["gsheet *"]` はコマンド文字列全体が `gsheet …` のときだけ一致する
    - 出力の JSON はそのまま読む。jq で整形しない
    - `set` / `append` / `api` の JSON は 3 つ目の引数で渡す。`<<<` や `<` の stdin は使わない。理由: ヒアストリングも除外の一致から外れる
    - `dangerouslyDisableSandbox` は使わない。auto mode の classifier に止められる
- `set` は values の形だけ書く。range より小さい values を送っても、残りのセルは消えない
- 消すときは `""` を送る。`null` は既存値を保持する
- range を単一セルで渡すと、そこを左上として values の形に書く。`A1` に `[["a","b"]]` を送ると B1 も更新される
- 認可エラーや project 未設定は `gsheet` が手順を表示する。人間の作業なのでユーザに渡す
- ファイル名からの検索は Drive connector に任せる。`gsheet` は URL か ID だけを受ける
