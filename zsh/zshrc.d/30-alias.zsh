# 日常操作の短縮名。
# ツール初期化に依存する alias もあるため、10-tool.zsh の後に読み込む。

alias ..="cd .."
alias compose="docker compose"
alias ls="ls -a -G"
alias rm="trash"
alias reload="exec $SHELL -l"
alias conf-zshrc='code ~/.zshrc'
alias conf-ghostty='code "$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty"'
alias conf-cmux='code ~/.config/cmux/cmux.json'
alias grep='/usr/local/opt/grep/libexec/gnubin/grep'


# lazyvim - https://github.com/LazyVim/LazyVim
export EDITOR=vim
alias vim="nvim"
