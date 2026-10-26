# TASK-261022: eMudhra 中間 CA 漏洩への端末対応

261022 eMudhra 中間 CA 漏洩への端末対応
===

## asis

- eMudhra の中間 CA 8 件は、公開証明書から秘密鍵を復元できる。P-384 の秘密鍵が 256 未満の値だった
- 8 件は 2025-04-30 生成。2026-10-17 に報告、10-18 に失効、10-20 に公開された
- 各鍵は emSign Root TLS CA - G3 発行と、Sectigo AAA Certificate Services のクロス証明書の 2 枚ずつある
- ブラウザは失効リストで遮断済み。Chrome は CRLSet、Firefox は OneCRL、Apple は 10-19、Microsoft は 10-20
- 2026-10-22 時点で、この Mac の CLI 系はテストホストを信頼した

| 対象 | 現状 | 判定 |
|---|---|---|
| macOS 26.6.2 の trust 判定 | `security verify-cert` が No error | 未ブロック |
| `/usr/bin/curl` | 200 で接続成功 | 信頼したまま |
| Node 24.19.0 (mise) | fetch 成功 | 信頼したまま |
| Python 3.13.7 (mise) | `/etc/ssl/cert.pem` 参照で成功 | 信頼したまま |
| Homebrew ca-certificates | 2026-08-13 | 古い |
| uv 0.12.13 / pip 24.3.1 | 修正版未満 | 古い |
| Chrome 155 / Firefox 156.0 | 失効リストは別経路で配信 | 更新推奨 |

## tobe

- ブラウザと macOS は最新版にする。失効リストが届いている
- mise 管理の Node / Python 系は修正版にする。古い Node は消す
- CA bundle 系は 2026-10-20 版以降にする
- 残リスクは受け入れる。理由: クロス証明書は bundle 更新だけでは防げない。CLI は接続先が固定で影響は小さい

## todo

- [x] `brew upgrade --cask firefox` で 158.0.1 にした。理由: 未起動だったので安全に差し替えられた
- [x] Chrome の CRLSet 10853 に EM EV TLS CA - G3B の SPKI が入っていた。遮断は有効
- [ ] 人間: Chrome 本体を更新する。起動中だったので cask upgrade は見送った。再起動で自動更新される
- [ ] 人間: `softwareupdate --install --all` で macOS を更新する
- [x] `mise/mac.toml` の node を 24.22.1 にする。`mise install` する
- [x] `mise/win.toml` の node を 24.22.1 にする
- [ ] 人間: Windows サブ機で `windows/copy-configs.sh` を流し、`mise install` する
- [ ] 人間: `mise uninstall node@16.14.0 node@18.19.1`。理由: EOL で修正されない
- [ ] 人間: `mise uninstall node@22.19.0 node@24.14.1`。残すなら 22.23.4 以上にする
- [x] `mise/mac.toml` の firebase を `npm:firebase-tools` にした。理由: 単体バイナリ版は node v20.18.2 を内蔵し、最新 15.34.1 も同じ
- [x] 人間: `mise uninstall firebase --all` で単体バイナリ版を消す
- [x] `mise upgrade uv` で 0.13.5 にした。理由: uv は mise 管理なので `uv self update` は使わない
- [x] `python3 -m pip install -U pip` で 26.2.2 にした
- [x] `brew upgrade ca-certificates` で 2026-10-20 版にした。依存の ffmpeg / poppler も上がった
- [ ] 人間: certifi を使う project は 2026.10.19 以上にする
- [ ] 人間: Docker の base image を pull し直し、image を rebuild する
- [ ] 人間: システム curl の扱いを決める。brew の curl を使うか、手動 distrust するか

## testcases

- [x] `node -e` で以下の URL を fetch し、拒否される。24.22.1 は CERT_REVOKED、24.19.0 は 200 だった
- [ ] `python3 -c` で以下の URL を開き、拒否される
- [ ] `security verify-cert` で以下の URL の chain が拒否される
- [ ] `mise ls node` に 24.22.1 以上だけ残る
- [x] `zsh -n bin/dots` / `dots doctor`

テスト URL: `https://ev-g3b-emudhra.we-have-a-problem.com/`
接続が成功したら、その client はまだ信頼している。

## notes

- 2026-10-23: brew の ca-certificates 2026-10-20 版はテスト URL を拒否した。`curl --cacert /opt/homebrew/etc/ca-certificates/cert.pem` で確認
- 2026-10-23: mise の Python は `/etc/ssl/cert.pem` を見るので、まだ信頼する。`SSL_CERT_FILE` で brew bundle を向けるかは未決。理由: zsh に Homebrew prefix を書かない方針
- 2026-10-23: 起動済み shell の `node --version` は 24.19.0 のまま。新しい shell で 24.22.1 になる
- Node 22.23.4 / 24.22.1 / 26.12.1 は 2026-10-21 の security release でもある。High 4 件を含み、Brotli decoder の RCE (CVE-2026-111497) はサーバ側にも効く。web サーバの Node bump は CA 対応と切り離して優先する
- https://nodejs.org/ja/blog/vulnerability/october-2026-security-releases
- 修正版: Firefox 158.0.1 / ESR 153.5.1 / ESR 115.43.1, Node 22.23.4 / 24.22.1 / 26.12.1, Go 1.27.3 / 1.26.10, certifi 2026.10.19, pip 26.2.2, uv 0.13.4, Electron 44.9.1 / 43.8.1 / 42.11.16
- Go と Bun はこの Mac に無い。入れるときは修正版にする
- Apple の trust store asset は 2026062400 だった。Apple の遮断がこの端末へ届いたかは未確認
- macOS 標準 curl は失効を見ない。手動 distrust の手順は公開サイトにある
- Chrome は 2026-10-27 に emSign ECC Root CA - G3 を root から外す
- 悪用の確認は無い。ただし鍵は 17 か月露出した
- https://bugzilla.mozilla.org/show_bug.cgi?id=2083449
- https://ctlogs.dev/blog/emudhra-ca-compromise
- https://socradar.io/blog/emudhra-ca-key-compromise-weak-keys-risks-and-fixes/
- https://emudhra.we-have-a-problem.com/
