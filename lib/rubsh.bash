export RUBSH_PATH+=${RUBSH_PATH:+:}$(unset -v CDPATH; cd "$(dirname $BASH_SOURCE)" && pwd):.
source "$(dirname $BASH_SOURCE)"/keywords.rubsh
require utils

initialize_rubsh

rubsh_main () {
  local class
  local classes=(
    object
    class
    string
    array
    hash
    file
  )

  for class in "${classes[@]}"; do
    require "$class"
  done
}

rubsh_main
rubsh_cleanup
