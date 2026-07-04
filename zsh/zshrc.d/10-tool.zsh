# ツール依存の初期化を集約する。
# 方針: コマンドごとに細かく分けるより、「この環境が依存しているツール」をここで一覧できるようにする。

# user-local commands managed by this dotfiles repository and other tools
export PATH="$HOME/.local/bin:$PATH"

# GNU grep
export PATH="/usr/local/opt/grep/libexec/gnubin:$PATH"

# php@8.1 remains Homebrew-managed until mise php build dependencies are settled.
export PATH="/usr/local/opt/php@8.1/bin:$PATH"
export PATH="/usr/local/opt/php@8.1/sbin:$PATH"

# fd + fzf + bat
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .*'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
source <(fzf --zsh)

# https://github.com/docker/for-win/issues/14021
export COMPOSE_MENU=0

# direnv
eval "$(direnv hook zsh)"

# mise
eval "$(/Users/yano3/.local/bin/mise activate zsh)"

# Vite+ bin (https://viteplus.dev)
. "$HOME/.vite-plus/env"
