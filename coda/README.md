# Coda

自作 editor tool [Coda](https://github.com/yano3nora/coda) の手書き設定。

`dots link` により、次のリンクを作る。

- `~/.config/coda/config.toml` -> `coda/config.toml`
- `~/.config/coda/bindings.json` -> `coda/bindings.json`

`generated/` と `import-reports/` は Coda が生成する派生物のため管理しない。再生成結果や端末環境に依存する内容を Git の正本に混ぜないためである。

`bindings.json` は JSONC としてコメントを記述できる。`command` には VS Code の command ID ではなく、Coda の内部 action 名を指定する。

設定項目が Coda 側の更新で変更された場合、古い設定が読み込めなくなる可能性がある。Coda 更新後は起動とキーマップを確認する。
