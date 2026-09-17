# 日常操作の短縮名。
# ツール初期化に依存する alias もあるため、10-tool.zsh の後に読み込む。

alias ..="cd .."
alias compose="docker compose"
alias ls="ls -a -G"
alias rm="trash"
alias reload="exec $SHELL -l"
alias chrome='open -a "Google Chrome"'
alias cdw="cd ~/Downloads"
alias cdg="cd ~/git"
alias cdd="cd ~/git/yano3nora/dotfiles"

# coda - https://github.com/yano3nora/coda
# 意図: git commit など `$EDITOR` を実行するツールでも coda を使う。
# やっていること: alias は非対話コマンドから参照されないため、EDITOR 自体を coda にする。
export EDITOR=coda
export VISUAL="$EDITOR"
