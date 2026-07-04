# awsp: AWS profile を fzf で選択して現在の shell に反映する。
function awsp() {
  local profile
  profile="$(aws configure list-profiles | fzf --prompt='AWS_PROFILE> ')" || return

  if [[ -z "$profile" ]]; then
    return 1
  fi

  export AWS_PROFILE="$profile"
  echo "AWS_PROFILE=$AWS_PROFILE"
}
