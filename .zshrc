#
# User configuration
#
export PATH=$HOME/.local/bin:$PATH
alias ..="cd .."
alias compose="docker compose"
alias ls="ls -a -G"
alias rm="trash"
alias reload="exec $SHELL -l"

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
function mkd() { mkdir -p $@ && cd $_ && pwd }

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
    fc -l -r 1 \
      | sed -E 's/^[[:space:]]*[0-9]+[[:space:]]+//' \
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

# isodate - epoch millis から iso 日時を返す
# brew install coreutils で gdate コマンド実行できる前提
isodate() {
  # 引数がなければ gdate +%s%3N で今のミリ秒を取得
  local ts=${1:-$(gdate +%s%3N)}
  # 秒部とミリ秒部に分割して ISO 形式でフォーマット
  TZ=Asia/Tokyo gdate -d "@$((ts/1000)).$((ts%1000))" '+%Y-%m-%dT%H:%M:%S.%3N%:z'
}

# safezip - どの OS でも文字化けしないよう NFC / UTF-8 な zip を作成する
# brew install convmv で convmv コマンド実行でき
# brew install zip で zip を入れ直して PATH を通している前提
# e.g.) $ safezip src/ [out.zip]
export PATH="/usr/local/opt/zip/bin:$PATH"
safezip() (
  set -euo pipefail
  src="${1%/}"
  out="${2:-${src##*/}.zip}"
  base="${src##*/}"
  [ -e "$src" ] || { echo "❌ Not found: $src" >&2; exit 1; }

  dest_dir="$(dirname -- "$out")"
  dest_name="$(basename -- "$out")"
  if [ "$dest_dir" = "." ]; then
    dest="$PWD/$dest_name"
  else
    dest="$(cd "$dest_dir" && pwd -P)/$dest_name"
  fi

  tmp="$(mktemp -d "${TMPDIR:-/tmp}/safezip.XXXXXX")"
  trap 'rm -rf -- "$tmp"' EXIT
  if [ -d "$src" ]; then
    mkdir -p "$tmp/$base" && cp -R "$src"/. "$tmp/$base"/
  else
    cp "$src" "$tmp/$base"
  fi

  cd "$tmp"
  # convmv の --nfc で NFC 正規化へコンバート
  # コンバート時にエンコーディング指定が必要なので -f utf-8 -t utf-8 をつけてる
  convmv -r -f utf-8 -t utf-8 --notest --nfc "$base"
  # -UN が --unicode オプション、ここで UTF-8 フラグをつけてる
  # ついでにありがちな .DS_Store とか消したり
  zip -r -X -UN=UTF8 "$dest" "$base" -x "*/.DS_Store" "*/__MACOSX/*"

  echo "✅ Generated: $dest"
)
