> https://github.com/topics/dotfiles

# Distribution
```sh
$ git clone xxx
$ cd dotfiles/
$ mv ~/.zshrc ~/.zshrc.bak
$ ln -s $(pwd)/.zshrc ~/
```

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
