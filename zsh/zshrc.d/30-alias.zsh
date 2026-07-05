# 日常操作の短縮名。
# ツール初期化に依存する alias もあるため、10-tool.zsh の後に読み込む。

alias ..="cd .."
alias compose="docker compose"
alias ls="ls -a -G"
alias rm="trash"
alias reload="exec $SHELL -l"
alias grep='/usr/local/opt/grep/libexec/gnubin/grep'

# conf
alias conf-zshrc='code ~/.zshrc'
alias conf-ghostty='code "$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty"'
alias conf-codex='code ~/.codex/instructions.md'
alias conf-claude='code ~/.claude/CLAUDE.md'
alias conf-mise='code ~/.config/mise/config.toml'

# lazyvim - https://github.com/LazyVim/LazyVim
# 意図: git commit など `$EDITOR` を実行するツールでも LazyVim / nvim を使う。
# やっていること: alias は非対話コマンドから参照されないため、EDITOR 自体を nvim にする。
export EDITOR=nvim
export VISUAL="$EDITOR"
alias vim="nvim"
