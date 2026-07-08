# TASK-260707: brew 管理 CLI ツールの mise 移行・棚卸し

260707 brew 管理 CLI ツールの mise 移行・棚卸し
===

## asis

- `brew leaves` に約60個の formula があり、ライブラリ依存/build依存/GUIアプリ/実務CLIツールが混在している
- `mise/config.toml` にはすでに `aws-cli = "latest"` があるが、brew 側にも `awscli` / `aws-sam-cli` が別途インストールされており、管理主体が二重化している
- 旧方針では全 global CLI を explicit pin 対象にしていたが、日常CLIまで pin すると運用コストが高い
- `firebase` は brew ではなく `~/.vite-plus/bin/firebase` という standalone install で管理されており、管理主体が不明瞭
- 便利だが存在を忘れがちな単体CLI (bat, fd, fzf, gh, wget, yazi, trash, zip, neovim) が mise 未管理のまま brew に残っている
- httpie, translate-shell など、現状ほぼ使っていない可能性があるツールも残ったままになっている

## tobe

- version が実務に影響する runtime / deploy CLI の管理主体が明確になり、mise/brew/standalone の二重管理が解消されている
- 日常使いの便利ツールは、必要なら `mise/config.toml` に集約しつつ `latest` 追従を許容する
- 使っていないツールは根拠を確認した上で削除されている
- 移行が一気にではなく、空いた時間に1つずつ検証しながら進められる状態になっている

## todo

### runtime / deploy 系 (version が重要)

- [ ] `awscli` / `aws-sam-cli` と mise の `aws-cli` の重複を整理する（brew側を削除するか mise側に寄せるか判断）
- [ ] `aws-cli` を deploy 系として explicit version にする必要があるか判断する
- [ ] `copilot-cli` の管理方法を検討する（brew管理継続 or mise化）
- [ ] `firebase` (`~/.vite-plus/bin/firebase`) の管理主体を確認し、mise化 or 現状維持を決める
- [ ] `gemini-cli` も同じ性質（ベンダーCLI・頻繁更新）なので同じ検討対象に含めるか判断する

### 便利だけど存在忘れがちツール系 (`latest` 許容)

- [ ] `zip` を mise 管理に移行する
- [ ] `neovim` を mise 管理に移行する
- [ ] `trash` を mise 管理に移行する
- [ ] `bat` を mise 管理に移行する
- [ ] `fd` を mise 管理に移行する
- [ ] `fzf` を mise 管理に移行する
- [ ] `gh` を mise 管理に移行する
- [ ] `wget` を mise 管理に移行する
- [ ] `yazi` を mise 管理に移行する

### 削除対象 (使用実態を確認して削除)

- [ ] `httpie` の利用有無を確認し、未使用なら `brew uninstall`
- [ ] `translate-shell` の利用有無を確認し、未使用なら `brew uninstall`

### 未トリアージ (上記3分類にまだ入れていない brew leaves)

- [ ] automake, bison, re2c, guile, gnu-units, mcrypt, convmv, docutils, ijq, jless, hunk, pdm, peco, difftastic, btop, coreutils, direnv, exiftool, fastfetch, git-delta, gitleaks, grep, imagemagick, ghostscript, ffmpeg, openvino, portaudio, powerlevel10k, macvim, php@8.1, rustup, python@3.10, python@3.11, python@3.8 を上記3分類のどこに入れるか判断する

## testcases

- [ ] mise 化したツールは `which <tool>` が `~/.local/share/mise/...` 配下を指しているか確認する
- [ ] `dots doctor` が該当ツールを正しく検知するか確認する
- [ ] brew uninstall 後、既存のシェル設定・alias・スクリプト (`zsh/`, `bin/`) が壊れていないか確認する
- [ ] `zsh -n zsh/zshrc` / `zsh -n bin/dots` が通ることを確認する

## notes

- 移行は1ツールずつ: `mise use -g <tool>@latest` または `mise use -g <tool>@<version>` → 動作確認 → 必要なら `brew uninstall <tool>` の順で進める。一括移行はしない。
- `jq` / `ripgrep` などの日常CLIは `latest` でよい。Node や Copilot / Firebase など、project や deploy 結果に影響するものは explicit version を優先する。
- ビルド依存が重い/OS依存が強いもの（imagemagick, ffmpeg, ghostscript, php@8.1, macvim, powerlevel10k, openvino, guile 等）は AGENTS.md の例外ルール通り brew 管理を継続する前提。
- rustup は mise の rust backend と役割が競合する可能性があるため、mise化は保留し brew 管理を継続する方向で検討する。
- 参照元: 2026-07-07 の brew→mise 移行相談。
