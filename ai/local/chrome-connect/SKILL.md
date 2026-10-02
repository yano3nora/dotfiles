---
name: chrome-connect
description: chrome-devtools CLI をユーザが普段使っている Chrome 本体 (実タブ・ログイン状態・localStorage 込み) へ接続する。「chrome-devtools で確認して」「ブラウザで見て」「remote debug して」「用意したタブで検証して」と言われたら、daemon が別ブラウザを立ち上げる前にまずこれを使う。
---

# chrome-connect

chrome-devtools-mcp の daemon はデフォルトで自前の空ブラウザを起動するため、ユーザが用意したタブや進行中のアプリ状態 (localStorage 等) が見えない。ユーザの Chrome 本体へ WebSocket で直接接続する。

## 接続手順

```bash
P="$HOME/Library/Application Support/Google/Chrome/DevToolsActivePort" \
  && chrome-devtools stop; pkill -f chrome-devtools-mcp; sleep 1 \
  && chrome-devtools start --wsEndpoint "ws://127.0.0.1:$(sed -n 1p "$P")$(sed -n 2p "$P")" \
  && chrome-devtools list_pages
```

- `DevToolsActivePort` はポート番号と browser UUID パスの 2 行。**UUID は Chrome 再起動ごとに変わる**ため毎回読み直す (ハードコード禁止)
- `list_pages` にユーザの実タブが並べば接続成功。目的のタブを `select_page <n>` して操作する

## 前提と注意

- Chrome 側で chrome://inspect/#remote-debugging のサーバが ON であること (ユーザ設定済み。「Server running at: 127.0.0.1:9222」表示が目印)。OFF なら ON にしてもらう
- `DevToolsActivePort` が読めない・接続失敗 → Chrome 側サーバが OFF か Chrome 未起動。ユーザに確認する
- この接続はユーザの全タブを操作できる。**検証が終わったら `chrome-devtools stop`**
- 既知の罠 (v1.7.0): `chrome-devtools stop` が daemon を殺しきれないことがあるため、接続し直す時は上記のように `pkill -f chrome-devtools-mcp` を挟む。`start --autoConnect` は exit 0 のまま daemon が即死するので使わない (修正されたら --autoConnect 一発に置き換えてよい)
- curl で `http://127.0.0.1:9222/json/version` は 404 になるが正常 (新方式サーバは旧 HTTP discovery を提供しない)。疎通確認には使えない
