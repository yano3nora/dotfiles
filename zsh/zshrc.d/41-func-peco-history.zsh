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
