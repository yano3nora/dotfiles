# ツール依存の初期化を集約する。
# 方針: コマンドごとに細かく分けるより、「この環境が依存しているツール」をここで一覧できるようにする。
# 方針: Homebrew の prefix (Intel /usr/local, Apple Silicon /opt/homebrew) に依存する PATH は書かない。
#       brew は build / OS 依存の例外だけに使い、CLI の入口は mise に揃える (mise/README.md)。

# user-local commands managed by this dotfiles repository and other tools
export PATH="$HOME/.local/bin:$PATH"

# Homebrew (Apple Silicon)
# Intel は /usr/local/bin が標準 PATH に含まれるが、/opt/homebrew/bin は含まれないので brew 自身に PATH を設定させる。
# mise activate より前に置き、mise 管理のコマンドが brew のものより優先されるようにする。
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# mise
# fzf / direnv など mise 管理のコマンドをこのファイル内で呼ぶため、他ツールの初期化より先に PATH を通す。
eval "$(mise activate zsh)"

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

# Docker Desktop が ~/.zshrc 末尾へ追記してくる CLI 補完を repo 管理に置き換えたもの。
# 20-zsh.zsh の compinit より前に fpath へ足す必要がある (再追記されたら消してよい)。
[ -d "$HOME/.docker/completions" ] && fpath=("$HOME/.docker/completions" $fpath)

# https://github.com/docker/for-win/issues/14021
export COMPOSE_MENU=0

# direnv
# 意図: direnv の `direnv: loading ...` ログは初回 precmd で出力されるため、
# p10k instant prompt (00-initial.zsh) に console 出力として検知され WARNING になる。
# ログ自体にほぼ情報量がないので空 format で常時黙らせる。
export DIRENV_LOG_FORMAT=""
eval "$(direnv hook zsh)"

# 各 installer が HOME に置く env。未導入の機で壊れないよう存在する時だけ読む。
# rustup (https://rustup.rs)
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
# Vite+ (https://viteplus.dev)
[[ -f "$HOME/.vite-plus/env" ]] && . "$HOME/.vite-plus/env"
