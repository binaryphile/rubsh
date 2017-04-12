source "$(dirname $BASH_SOURCE)"/utils.rubsh
$(package rubsh)
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
