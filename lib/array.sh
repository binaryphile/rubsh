#!/usr/bin/env bash
# Functions for array manipulation

[[ -z $_rubsh_array ]] || return 0

# shellcheck disable=SC2046,SC2155
declare -r _rubsh_array="$(set -- $(sha1sum "$BASH_SOURCE"); printf "%s" "$1")"

source "${BASH_SOURCE%/*}"/core.sh 2>/dev/null || source core.sh

_rubsh_init() {
  local aliases

  # shellcheck disable=SC2034
  read -d "" -a aliases <<EOS
to_s
EOS

  _rubsh.core.alias Array aliases
}

_rubsh_init
unset -f _rubsh_init

_rubsh.sh.alias_function Array.== Array.eql?

Array.eql? () {
  local _array1="$1"
  local _array2="$2"
  local i

  _rubsh.sh.deref _array1
  _rubsh.sh.deref _array2
  [[ ${#_array1[@]} -eq ${#_array2[@]} ]] || return 1
  for i in "${!_array1[@]}"; do
  [[ ${_array1["$i"]} == "${_array2["$i"]}" ]] || return 1
  done
}

# https://stackoverflow.com/questions/3685970/check-if-an-array-contains-a-value#answer-8574392
Array.include? () {
  local elem
  local array

  array=( $(_rubsh.sh.value "$1") )
  for elem in "${array[@]}"; do
    if [[ $elem == "$2" ]]; then
      return 0
    fi
  done
  return 1
}

Array.index() {
  local array
  local i
  local item="$2"

  array=( $( _rubsh.sh.value "$1") )
  for i in "${!array[@]}"; do
    if [[ ${array[${i}]} == "$item" ]]; then
      printf "%s" "$i"
      return 0
    fi
  done
  return 1
}

# https://stackoverflow.com/questions/1527049/bash-join-elements-of-an-array#answer-17841619
Array.join() {
  local delim="$2"

  # shellcheck disable=SC2046
  set -- $(_rubsh.sh.value "$1")
  printf "%s" "$1"
  shift
  printf "%s" "${@/#/$delim}"
}

Array.new() {
  local method
  local methods

  # shellcheck disable=SC2034
  read -d "" -a methods <<EOS
==
eql?
include?
index
join
remove
slice
to_s
EOS

  for method in "${methods[@]}"; do
    _rubsh.core.alias_method "$1" "$method" "Array"
  done

  case ${#@} in
    1 )
      ;;
    2 )
      eval "$1=$2"
      ;;
    * )
      local _rubsh_arg="$1" && shift && _rubsh.sh.upvar "$_rubsh_arg" "$@"
      ;;
  esac
}

Array.remove() {
  local i
  local item
  local result

  item="$2"
  # shellcheck disable=SC2046
  set -- $(_rubsh.sh.value "$1")
  result=( )
  for i in "$@"; do
    [[ $i == "$item" ]] || result+=( "$i" )
  done
  # TODO: use _Array.to_s?
  cat <<< "${result[@]}"
}

Array.slice() {
  local first=$2
  local last=$3
  local array

  eval "local array=(\"\${$1[@]}\")"

  cat <<< "${array[@]:${first}:$((last-first+1))}"
}
