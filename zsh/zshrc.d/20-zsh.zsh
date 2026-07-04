# zsh 自体の設定を集約する。
# oh-my-zsh / p10k / completion / zle widget など、shell の挙動そのものを変えるものを置く。

# oh-my-zsh
plugins=(git zsh-autosuggestions)
export ZSH="/Users/yano3/.oh-my-zsh"
source "$ZSH/oh-my-zsh.sh"
source /Users/yano3/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/local/share/powerlevel10k/powerlevel10k.zsh-theme

# p10k
# - https://github.com/romkatv/powerlevel10k
# - https://zenn.dev/urakawa_jinsei/articles/dccd3dcfa0dc0e
# - (vscode settings) "terminal.integrated.fontFamily": "MesloLGS NF",
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=1
typeset -g POWERLEVEL9K_VCS_VISUAL_IDENTIFIER_EXPANSION=

# completion / suggestion
# Shift + Tab で auto complete 選択、Tab で suggestion の受け入れ
# Ctrl + → で suggestion の部分適用
autoload -Uz compinit && compinit
setopt auto_menu
setopt auto_list
zstyle ':completion:*:default' menu select=1
bindkey '^I' autosuggest-accept
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_USE_ASYNC=true

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
