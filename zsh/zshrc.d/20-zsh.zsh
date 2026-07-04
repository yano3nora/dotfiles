# zsh 自体の設定を集約する。
# p10k / completion / zle widget など、shell の挙動そのものを変えるものを置く。

if [[ -n "${ZSH_PROFILE:-}" ]]; then
  zmodload zsh/datetime
  __zsh_profile_last="$EPOCHREALTIME"
  function __zsh_profile_mark() {
    local label="$1"
    local now="$EPOCHREALTIME"
    local elapsed_ms=$(( (now - __zsh_profile_last) * 1000 ))
    printf 'zsh-profile 20-zsh %-28s %8.2fms\n' "$label" "$elapsed_ms" >&2
    __zsh_profile_last="$now"
  }
else
  function __zsh_profile_mark() { :; }
fi

# zsh-autosuggestions
# oh-my-zsh は使わず、必要な plugin だけを直接読み込む。
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_USE_ASYNC=true
source "$HOME/.local/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"
__zsh_profile_mark "autosuggestions"

source "$HOME/.local/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
__zsh_profile_mark "syntax-highlighting"

source /usr/local/share/powerlevel10k/powerlevel10k.zsh-theme
__zsh_profile_mark "p10k-theme"

# p10k
# - https://github.com/romkatv/powerlevel10k
# - https://zenn.dev/urakawa_jinsei/articles/dccd3dcfa0dc0e
# - (vscode settings) "terminal.integrated.fontFamily": "MesloLGS NF",
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=1
typeset -g POWERLEVEL9K_VCS_VISUAL_IDENTIFIER_EXPANSION=
__zsh_profile_mark "p10k-user-config"

# completion / suggestion
# Shift + Tab で auto complete 選択、Tab で suggestion の受け入れ
# Ctrl + → で suggestion の部分適用
autoload -Uz compinit && compinit
__zsh_profile_mark "compinit"

# zle keymap
# 意図: EDITOR=vim などに引っ張られて vi mode になり、Ctrl + 矢印などで
# NORMAL / VISUAL 表示へ切り替わる事故を防ぐ。
# やっていること: 明示的に emacs keymap を使い、主要 terminal の Ctrl/Option + ←/→
# escape sequence を word 移動に割り当てる。
bindkey -e
bindkey '^[b' backward-word
bindkey '^[f' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word
bindkey '^[OD' backward-word
bindkey '^[OC' forward-word
bindkey '^[[D' backward-char
bindkey '^[[C' forward-char
__zsh_profile_mark "keymap"

setopt auto_menu
setopt auto_list
zstyle ':completion:*:default' menu select=1
bindkey '^I' autosuggest-accept
__zsh_profile_mark "completion-options"

# Tab: autosuggest が出てたら採用、なければ通常補完
function __tab_accept_suggest_or_complete() {
  # 意図: VSCode でも「半透明の提案を Tab で確定」したい
  # やってること: 提案が出てる時に入る POSTDISPLAY を見て分岐する
  if [[ -n "$POSTDISPLAY" ]]; then
    zle autosuggest-accept
  else
    zle expand-or-complete
  fi
}
zle -N __tab_accept_suggest_or_complete
bindkey '^I' __tab_accept_suggest_or_complete
__zsh_profile_mark "tab-widget"

unfunction __zsh_profile_mark 2>/dev/null || true
unset __zsh_profile_last
