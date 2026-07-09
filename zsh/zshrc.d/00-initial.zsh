# 先頭で読み込む必要がある初期化。
# ここには「速くするため」または「後続の初期化前でないと意味がない」ものだけ置く。

# Powerlevel10k instant prompt.
# 意図: zshrc 全体の読み込みを待たずにプロンプトを描画して体感起動を速くする。
# 注意: これ以降の初期化 (10-tool の direnv/mise 含む) が console 出力すると
# instant prompt に検知されて WARNING が出るため、各 hook は黙らせる運用にする。
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
