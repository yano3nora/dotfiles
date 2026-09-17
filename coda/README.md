# Coda

自作 editor tool [Coda](https://github.com/yano3nora/coda) の設定。

`dots link` により、次のリンクを作る。

- `~/.config/coda/config.toml` -> `coda/config.toml`
- `~/.config/coda/bindings.json` -> `coda/bindings.json`
- `~/.config/coda/generated/vscode-bindings.json` -> `coda/generated/vscode-bindings.json`

`config.toml` と `bindings.json` は手書き設定。

`generated/vscode-bindings.json` は `coda keymap import vscode` の生成物。
正本は `vscode/keybindings.json` で、Coda は他 editor から都度 import し直す設計。
生成物も repo に置く。理由: 新機で import を忘れると keymap が消える。
VSCode の keybindings を変えたら import し直し、差分を commit する。

```sh
coda keymap import vscode vscode/keybindings.json --dry-run --print-report
coda keymap import vscode vscode/keybindings.json
```

`import-reports/` は import の report で、管理しない。

`bindings.json` は JSONC としてコメントを記述できる。`command` には VS Code の command ID ではなく、Coda の内部 action 名を指定する。

設定項目が Coda 側の更新で変更された場合、古い設定が読み込めなくなる可能性がある。Coda 更新後は起動とキーマップを確認する。
