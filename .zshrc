#
# User configuration
#
export PATH=$HOME/.local/bin:$PATH
alias ..="cd .."
alias compose="docker compose"
alias ls="ls -a -G"
alias rm="trash"
alias reload="exec $SHELL -l"
alias conf-zshrc='code ~/.zshrc'
alias conf-ghostty='code "$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty"'
alias conf-cmux='code ~/.config/cmux/cmux.json'

# fd + fzf + bat
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .*'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
source <(fzf --zsh)

# deno
export PATH="/Users/yano3/.deno/bin:$PATH"

# gnubin
export PATH="/usr/local/opt/grep/libexec/gnubin:$PATH"
alias grep='/usr/local/opt/grep/libexec/gnubin/grep'

# php
export PATH="/usr/local/opt/php@8.1/bin:$PATH"
export PATH="/usr/local/opt/php@8.1/sbin:$PATH"

# https://github.com/docker/for-win/issues/14021
export COMPOSE_MENU=0

# direnv
eval "$(direnv hook zsh)"

# mise
eval "$(/Users/yano3/.local/bin/mise activate zsh)"

# Vite+ bin (https://viteplus.dev)
. "$HOME/.vite-plus/env"

# https://zenn.dev/ryu022304/scraps/1a702c7a1edfa0
alias awsp='export AWS_PROFILE=$(aws configure list-profiles | fzf)'

# lazyvim - https://github.com/LazyVim/LazyVim
export EDITOR=vim
alias vim="nvim"

#
# oh-my-zsh
#
plugins=(git zsh-autosuggestions)
export ZSH="/Users/yano3/.oh-my-zsh"
source $ZSH/oh-my-zsh.sh
source /Users/yano3/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/local/share/powerlevel10k/powerlevel10k.zsh-theme

#
# p10k
# - https://github.com/romkatv/powerlevel10k
# - https://zenn.dev/urakawa_jinsei/articles/dccd3dcfa0dc0e
# - (vscode settings) "terminal.integrated.fontFamily": "MesloLGS NF",
#
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=1
typeset -g POWERLEVEL9K_VCS_VISUAL_IDENTIFIER_EXPANSION=

#
# completion / suggestion
#
# Shift + Tab で auto complete 選択、Tab で suggestion の受け入れ
# Ctrl + → で suggestion の部分適用
#
autoload -Uz compinit && compinit
setopt auto_menu
setopt auto_list
zstyle ':completion:*:default' menu select=1
bindkey '^I'      autosuggest-accept
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

#
# functions
#
function mkd() {
  if [[ $# -ne 1 ]]; then
    echo "使い方: mkd <dir>" >&2
    return 1
  fi

  local dir="$1"
  mkdir -p -- "$dir" && cd -- "$dir" && pwd
}

# pd: current dir 以下からディレクトリを peco で選択して cd する
function pd() {
  local dir
  dir=$(
    command find . -type d \
      -maxdepth 3 \
      -not -path '*/\.*' \
      -print 2>/dev/null \
    | sed 's|^\./||' \
    | awk '
      {
        # 深さ = "/" の個数（区切りが多いほど深い）
        depth = gsub(/\//, "/", $0)
        # "depth<TAB>path" の形にしてソートしやすくする
        printf("%04d\t%s\n", depth, $0)
      }
    ' \
    | sort -t $'\t' -k1,1n -k2,2 \
    | cut -f2- \
    | peco --prompt='PECOCD> '
  )

  if [[ -n "$dir" ]]; then
    cd -- "$dir"
  fi
}

# Ctrl+R: history -> peco
function peco-history() {
  local selected
  selected=$(
    # fc: zsh builtin history
    # -l 1: 全履歴を一覧
    # -n: 番号なし（環境で挙動差あるけどOK）
    # zsh の fc は履歴番号の直後に "*" を付けることがあるため、番号 + 任意の "*" を除去する
    fc -l -r 1 \
      | sed -E 's/^[[:space:]]*[0-9]+\*?[[:space:]]+//' \
      | awk '!seen[$0]++' \
      | peco --prompt='HISTORY> '
  )

  if [[ -n "$selected" ]]; then
    BUFFER="$selected"
    CURSOR=${#BUFFER}
    zle redisplay
  fi
}
zle -N peco-history
bindkey '^R' peco-history
