# fzd: current dir 以下からディレクトリを fzf で選択して cd する。
function fzd() {
  local dir
  dir=$(
    # fd は並列走査で出力順が不定なため、深さ順（浅い→深い）+ path 昇順に整えてから fzf へ渡す。
    # fd の default で hidden / .gitignore 対象（node_modules 等）は除外される。
    # fzf は --exact + --no-sort で peco 時代（IgnoreCase filter）の substring マッチ + 並び固定を再現する。
    # fuzzy だと 1 文字ずつ飛び飛びにマッチした候補がノイズになるため使わない。fuzzy したい term だけ ' prefix で戻せる。
    fd --type d --max-depth 3 --strip-cwd-prefix 2>/dev/null \
    | awk '
      {
        # 深さ = "/" の個数（区切りが多いほど深い）
        # "depth<TAB>path" の形にしてソートしやすくする
        printf("%04d\t%s\n", gsub(/\//, "/", $0), $0)
      }
    ' \
    | sort -t $'\t' -k1,1n -k2,2 \
    | cut -f2- \
    | fzf --prompt='FZD> ' --exact --no-sort --cycle --reverse
  )

  if [[ -n "$dir" ]]; then
    cd -- "$dir"
  fi
}
