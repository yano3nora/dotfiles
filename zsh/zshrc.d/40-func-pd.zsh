# pd: current dir 以下からディレクトリを peco で選択して cd する。
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
