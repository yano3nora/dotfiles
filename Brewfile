# brew 側の唯一の入口。`brew bundle` で適用する。
# 方針: CLI の入口は mise/config.toml に揃え、brew は build / OS 依存の例外と GUI アプリ・フォントだけに使う。
# 方針: 必要になった時に個別に入れるもの (php, git-lfs, 各種 SDK など) はここに書かない。

tap "aws/tap"

# CLI (bin/ や zsh/ から使う、mise に無い / build 依存が重いもの)
brew "trash"       # 30-alias.zsh の rm
brew "zip"         # bin/safezip
brew "convmv"      # bin/safezip
brew "ffmpeg"      # bin/ffcomp
brew "exiftool"
brew "wget"
brew "btop"
brew "pv"

# 設定を dotfiles で管理しているアプリ
cask "visual-studio-code"
cask "ghostty"
cask "raycast"
cask "rectangle"
cask "clipy"
cask "betterdisplay"
cask "google-japanese-ime"

# フォント (ghostty/config.ghostty, vscode/settings.json, zsh/p10k.zsh が参照する)
cask "font-jetbrains-mono-nerd-font"
cask "font-meslo-lg-nerd-font"
cask "font-biz-udgothic"

# 日常アプリ
cask "1password"
cask "google-chrome"
cask "docker"
cask "claude"
cask "codex"
cask "slack"
cask "discord"
cask "tableplus"
cask "postman"
cask "charles"
cask "figma"
cask "firefox"
cask "obs"
cask "keycastr"
