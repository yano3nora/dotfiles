> https://github.com/topics/dotfiles

# Distribution
```sh
$ git clone xxx
$ cd dotfiles/
$ mv ~/.zshrc ~/.zshrc.bak
$ ln -s $(pwd)/.zshrc ~/
```

## VSCode
`settings.json` は `~/` 直下ではなく Application Support 配下にあるため、リンク先を明示する。

```sh
$ SETTINGS="$HOME/Library/Application Support/Code/User/settings.json"
$ mv "$SETTINGS" "$SETTINGS.bak"
$ ln -s "$(pwd)/vscode/settings.json" "$SETTINGS"
```

`vscode/github-markdown.css` は Markdown プレビュー用のスタイル。
ローカル参照は webview の制約で不可なため、jsDelivr 経由で `markdown.styles` から読む。

- 配信 URL: `https://cdn.jsdelivr.net/gh/yano3nora/dotfiles@main/vscode/github-markdown.css`
- CSS 更新後はキャッシュを purge する: `https://purge.jsdelivr.net/gh/yano3nora/dotfiles@main/vscode/github-markdown.css`
