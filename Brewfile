# brew 側の唯一の入口。`brew bundle` で適用する。
# 方針: CLI の入口は mise/config.toml に揃え、brew は build / OS 依存の例外と GUI アプリ・フォントだけに使う。
# 方針: 必要になった時に個別に入れるもの (php, git-lfs, 各種 SDK など) はここに書かない。

# CLI (bin/ や zsh/ から使う、mise に無い / build 依存が重いもの)
# trash は macOS 26 が /usr/bin/trash を標準搭載したので formula 不要 (30-alias.zsh の rm はそれを使う)
brew "zip"         # bin/safezip
brew "convmv"      # bin/safezip
brew "ffmpeg"      # bin/ffcomp
brew "exiftool"
brew "wget"
brew "btop"
brew "pv"
brew "mas"         # 下記 mas エントリ用。App Store サインイン + 入手済み履歴が前提

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
cask "font-meslo-for-powerlevel10k"  # "MesloLGS NF" (vscode/settings.json の terminal font 名と一致する p10k 公式 patch 版)

# 日常アプリ
cask "1password"
cask "google-chrome"
cask "docker-desktop"  # 旧 cask 名 "docker" から改名された
cask "claude"
# claude-code / codex (CLI) は brew に置かない特別経路。cask の更新ラグで新 model の要求 version に
# 間に合わないため、自動更新つきの公式 installer で ~/.local/bin に入れる:
#   curl -fsSL https://claude.ai/install.sh | bash
#   curl -fsSL https://chatgpt.com/codex/install.sh | sh
# brew 版が残っていると PATH で /opt/homebrew/bin が ~/.local/bin に勝つ (zsh/zshrc.d/10-tool.zsh) ので、
# 移行時は brew uninstall --cask claude-code codex を先に行う。
cask "slack"
cask "discord"
cask "tableplus"
cask "postman"
cask "charles"
cask "figma"
cask "firefox"
cask "obs"
cask "keycastr"
cask "imageoptim"
cask "microsoft-office"
cask "microsoft-teams"
cask "zoom"

# App Store 専売 (cask なし)
mas "Amazon Kindle", id: 302584613
mas "Klack", id: 6446206067
mas "Easy CSV Editor", id: 1171346381
mas "RunCat Neo", id: 6757801838
