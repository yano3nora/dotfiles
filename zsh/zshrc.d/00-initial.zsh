# 先頭で読み込む必要がある初期化。
# ここには「速くするため」または「後続の初期化前でないと意味がない」ものだけ置く。

# Powerlevel10k instant prompt.
# Initialization code that may require console input should stay above this block.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
