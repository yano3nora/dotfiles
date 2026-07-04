# mkd: ディレクトリを作成して、そのまま移動する。
function mkd() {
  if [[ $# -ne 1 ]]; then
    echo "使い方: mkd <dir>" >&2
    return 1
  fi

  local dir="$1"
  mkdir -p -- "$dir" && cd -- "$dir" && pwd
}
