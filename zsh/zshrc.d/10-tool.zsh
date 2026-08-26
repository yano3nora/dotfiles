# ツール依存の初期化を集約する。
# 方針: コマンドごとに細かく分けるより、「この環境が依存しているツール」をここで一覧できるようにする。

# user-local commands managed by this dotfiles repository and other tools
export PATH="$HOME/.local/bin:$PATH"

# GNU grep
export PATH="/usr/local/opt/grep/libexec/gnubin:$PATH"

# php@8.1 remains Homebrew-managed until mise php build dependencies are settled.
export PATH="/usr/local/opt/php@8.1/bin:$PATH"
export PATH="/usr/local/opt/php@8.1/sbin:$PATH"

# fd + fzf + bat
# --hidden: fd は標準で dotfile を除外するため明示する。.git 配下だけはノイズなので除外を維持。
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git --strip-cwd-prefix'
# Ctrl-T は候補を path 昇順に固定し、入力中も fzf の relevance 順へ並べ替えない。
# --exact: fuzzy だと 1 文字ずつ飛び飛びマッチの候補がノイズになるため substring マッチにする（peco の IgnoreCase filter 相当）。
# --cycle: 先頭で ctrl-p すると末尾へループする（末尾の候補へ一発で飛ぶ用途）。
# --preview: bat で中身を確認しながら選ぶ。--line-range で大きいファイルの読み込みを打ち切る。
# 入力欄が上・候補が下 (--reverse) は fzf の shell integration が Ctrl-T にだけ標準で付けている。
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND | sort"
export FZF_CTRL_T_OPTS="--exact --no-sort --cycle --preview 'bat --color=always --style=numbers --line-range=:200 {}'"
# Ctrl-R は fzf 標準 widget（recency 順・重複排除つき）を使う。
# --reverse: Ctrl-T と同じ「入力欄が上・候補が下」に揃える（standard では最新履歴が下に出る）。
export FZF_CTRL_R_OPTS='--cycle --reverse'
source <(fzf --zsh)

# https://github.com/aws/aws-sam-cli/issues/4329#issuecomment-1642388141
export DOCKER_HOST="unix://$HOME/.docker/run/docker.sock"

# https://github.com/docker/for-win/issues/14021
export COMPOSE_MENU=0

# direnv
# 意図: direnv の `direnv: loading ...` ログは初回 precmd で出力されるため、
# p10k instant prompt (00-initial.zsh) に console 出力として検知され WARNING になる。
# ログ自体にほぼ情報量がないので空 format で常時黙らせる。
export DIRENV_LOG_FORMAT=""
eval "$(direnv hook zsh)"

# mise
eval "$(mise activate zsh)"

# Vite+ bin (https://viteplus.dev)
. "$HOME/.vite-plus/env"
