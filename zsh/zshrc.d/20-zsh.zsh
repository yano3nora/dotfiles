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

# Powerlevel10k instant prompt.
# Delayed intentionally so project enter hooks can print before instant prompt starts.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
__zsh_profile_mark "p10k-instant-prompt"

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
# 意図: 何らかの拍子に zle が vi keymap へ切り替わり、入力が vim mode っぽくなる事故を抑止する。
# やっていること: line editor 開始時と keymap 変更時に、vi 系 keymap なら emacs keymap へ戻す。
function __force_emacs_keymap_if_vi() {
  if [[ "${KEYMAP:-}" == vicmd || "${KEYMAP:-}" == viins ]]; then
    zle -K emacs
  fi
}
zle -N zle-line-init __force_emacs_keymap_if_vi
zle -N zle-keymap-select __force_emacs_keymap_if_vi
bindkey '^[b' backward-word
bindkey '^[f' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[OD' backward-word
bindkey '^[OC' forward-word
bindkey '^[[D' backward-char
bindkey '^[[C' forward-char

# 意図: `autosuggest-accept-word` という名前で、suggestion を扱いやすい単位で部分採用する。
# やっていること: suggestion が path っぽい場合は次の `/` まで採用し、それ以外は
# zsh-autosuggestions の partial accept 対象である `forward-word` に委譲する。
# 例: `~/Downloads/hoge.txt` は `~/` -> `Downloads/` -> `hoge.txt` の単位で採用する。
function autosuggest-accept-word() {
  if [[ -n "$POSTDISPLAY" && "$POSTDISPLAY" == */* ]]; then
    local accept="${POSTDISPLAY%%/*}/"

    BUFFER+="$accept"
    POSTDISPLAY="${POSTDISPLAY#$accept}"
    CURSOR=${#BUFFER}
    zle -R
    return
  fi

  zle forward-word
}
zle -N autosuggest-accept-word
bindkey '^[[1;5C' autosuggest-accept-word

# CSI u (fixterms) ノイズ抑止
# 意図: Ghostty などが Ctrl+Shift+英字 等を `ESC [ <code> ; <mod> u` で送ってくると、
# zsh は `ESC [` までしか解釈できず残り (`105;6u` など) を入力行へ挿入してしまう。
# terminal 側 keybind で握りつぶすと nvim 等の TUI にもキーが届かなくなるため、
# ZLE (シェルの行編集) の間だけ no-op で食わせる。
# やっていること: printable 文字 (32-126) × 修飾キー (2=Shift .. 8=Shift+Alt+Ctrl) の
# CSI u 全パターンを no-op widget に bind する。
function __ignore_csi_u() { :; }
zle -N __ignore_csi_u
() {
  local code mod
  for code in {32..126}; do
    for mod in {2..8}; do
      bindkey "^[[${code};${mod}u" __ignore_csi_u
    done
  done
}
__zsh_profile_mark "keymap"

setopt auto_menu
setopt auto_list
# 意図: Ctrl+R / peco-history で `# ...` から始まる履歴を呼び出しても、
# `#` をコマンド名ではなくコメントとして扱わせる。
setopt interactive_comments
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
