dotfiles
===
> https://github.com/topics/dotfiles

macOS 用の個人 dotfiles。

# Structure
```txt
.
├ ai/                  … AI coding agent 向けの個人用グローバル設定
├ bin/                 … 個人用コマンド / dotfiles 管理コマンド
├ coda/                … Coda 設定
├ git/                 … Git global config
├ ghostty/             … Ghostty 設定
├ lazygit/             … LazyGit 設定
├ leaf/                … leaf 設定
├ mise/                … global mise 設定
├ nvim/                … LazyVim の個人カスタマイズ
├ project/             … 新規 project 用テンプレート
├ vscode/              … VSCode 設定
└ zsh/                 … zsh 設定
```

# Depends
- macOS
- zsh
- mise 2026+

# Development
## Getting Started
```sh
git clone xxx
cd dotfiles

# setup symlinks with backup
./bin/dots link

# setup tools
mise install
dots doctor

# reload shell
reload
```

`dots link` が作る主なリンク:

- `~/.config/dotfiles` -> this repository
- `git/gitconfig` -> `~/.gitconfig`
- `git/gitignore_global` -> `~/.gitignore_global`
- `~/.zshrc` -> `zsh/zshrc`
- `~/.config/mise/config.toml` -> `mise/config.toml`
- `~/.config/coda/config.toml` -> `coda/config.toml`
- `~/.config/coda/bindings.json` -> `coda/bindings.json`
- `~/.local/bin/*` -> `bin/*`
- VSCode / Ghostty / LazyGit / leaf 設定
- `~/.codex/instructions.md` -> `ai/CLAUDE.md`
- `~/.claude/CLAUDE.md` -> `ai/CLAUDE.md`
- `~/.claude/skills/*`, `~/.codex/skills/*` -> `ai/skills/*`
- `~/.config/nvim/lua/config/*.lua`, `~/.config/nvim/lua/plugins/blink.lua` -> `nvim/lua/...` (LazyVim starter は別途 clone しておく)

## Commands
```sh
dots link           # 管理対象の symlink を作る
dots doctor         # 必要なコマンドを確認する
dots addbin <name>  # bin/<name> を実行可能な雛形つきで作る
dots project [--typescript] [--react] [dir]
                    # 新規 project 用テンプレートをコピーする
```

## Workflows
### 個人用コマンドを追加する
```sh
dots addbin my-command
dots link
```

### 新規 project を初期化する
```sh
mkdir my-project
cd my-project

dots project
dots project --typescript
dots project --typescript --react
# tsc --init や Vite / Next.js など、project 固有の初期化に続く
# package.json の依存・バージョンの最適化は手動で行う
```

既存ファイルは上書きせず skip する。
コピー後は `AGENTS.md`, `README.md`, `docs/` の TODO を project 固有の内容に書き換える。

### 管理対象ファイルを増やす
1. repo に設定ファイルを置く
2. `bin/dots` の `link_all` に symlink を追加する
3. `dots link` を実行する

# MacBook Tuning
symlink やコマンドで管理できない、手で 1 回だけ流す macOS 側の設定。
新しい Mac に移るときはここを上から順に適用する。
項目ごとに「目的 / コマンド / 戻し方 / 適用日」を書く。

## 新テキストカーソル機能 (CursorUIViewService) の無効化
- 目的: macOS 26 でカーソル横の Caps Lock / 入力モード表示を担う `CursorUIViewService` が不可視 window を破棄せず溜め続け、数日で WindowServer が CPU 100% になる Apple 側バグの回避 (経緯は [`docs/TASK-260908-cursoruiviewservice-leak.md`](docs/TASK-260908-cursoruiviewservice-leak.md))
- 代償: Caps Lock / 入力モードの吹き出し表示が出なくなる
- コマンド (要再起動):
    ```sh
    sudo mkdir -p /Library/Preferences/FeatureFlags/Domain
    sudo defaults write /Library/Preferences/FeatureFlags/Domain/UIKit.plist redesigned_text_cursor -dict-add Enabled -bool NO
    ```
- 戻し方: 同じコマンドを `-bool YES` で実行して再起動
- 確認: `ps -A | grep CursorUIViewService` に何も出なければ効いている
- 適用日: 2026-09-08 (macOS 26.5.2)

# Deployment
release 運用はしない。
push / publish は人間が判断して実行する。

# Resources
- [`ai/README.md`](ai/README.md)
- [`bin/README.md`](bin/README.md)
- [`coda/README.md`](coda/README.md)
- [`git/README.md`](git/README.md)
- [`zsh/README.md`](zsh/README.md)
- [`project/README.md`](project/README.md)
- [`vscode/README.md`](vscode/README.md)
- [`ghostty/README.md`](ghostty/README.md)
- [`lazygit/README.md`](lazygit/README.md)
- [`leaf/README.md`](leaf/README.md)
- [`mise/README.md`](mise/README.md)
- [`nvim/README.md`](nvim/README.md)
