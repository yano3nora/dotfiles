> https://github.com/topics/dotfiles

# Distribution
```sh
$ git clone xxx
$ cd dotfiles/
$ ./bin/dotfiles install
```

## dotfiles command
`dotfiles install` は既存ファイルを上書きせず、`.bak.YYYYMMDDHHMMSS` に退避してから symlink を作成する。

```sh
$ dotfiles install # 設定を symlink して doctor も実行
$ dotfiles link    # 設定の symlink のみ作成
$ dotfiles doctor  # 必要なコマンドの有無を確認
```

`install` / `link` で作成する主なリンク:

- `~/.config/dotfiles` -> this repository
- `~/.zshrc` -> `zsh/zshrc`
- `~/.local/bin/*` -> `bin/*`
- VSCode settings / keybindings
- Ghostty config

## Zsh
Zsh 設定の実体は `zsh/zshrc` と `zsh/zshrc.d/*.zsh` に分割している。

`zsh/zshrc.d/` の分割方針:

- `00-initial.zsh` - 先頭で読み込む必要がある初期化
- `10-tool.zsh` - PATH や外部ツールのセットアップ
- `20-zsh.zsh` - oh-my-zsh / p10k / completion / zle など zsh 自体の設定
- `30-alias.zsh` - alias / editor 設定
- `40-func-*.zsh` - 関数。ファイル名で中身を想起できる単位に分ける

## VSCode
`settings.json` / `keybindings.json` は `~/` 直下ではなく Application Support 配下にあるため、リンク先を明示する。

```sh
$ SETTINGS="$HOME/Library/Application Support/Code/User/settings.json"
$ mv "$SETTINGS" "$SETTINGS.bak"
$ ln -s "$(pwd)/vscode/settings.json" "$SETTINGS"

$ KEYBINDINGS="$HOME/Library/Application Support/Code/User/keybindings.json"
$ mv "$KEYBINDINGS" "$KEYBINDINGS.bak"
$ ln -s "$(pwd)/vscode/keybindings.json" "$KEYBINDINGS"
```

`vscode/github-markdown.css` は Markdown プレビュー用のスタイル。
ローカル参照は webview の制約で不可なため、jsDelivr 経由で `markdown.styles` から読む。

- 配信 URL: `https://cdn.jsdelivr.net/gh/yano3nora/dotfiles@main/vscode/github-markdown.css`
- CSS 更新後はキャッシュを purge する: `https://purge.jsdelivr.net/gh/yano3nora/dotfiles@main/vscode/github-markdown.css`

## Ghostty
`config.ghostty` は `~/` 直下ではなく Application Support 配下にあるため、リンク先を明示する。

```sh
$ GHOSTTY_CONFIG="$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty"
$ mv "$GHOSTTY_CONFIG" "$GHOSTTY_CONFIG.bak"
$ ln -s "$(pwd)/ghostty/config.ghostty" "$GHOSTTY_CONFIG"
```
