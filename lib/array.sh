#!/usr/bin/env bash
# Functions for array manipulation

[[ -z $_rubsh_array ]] || return 0

# shellcheck disable=SC2046
readonly _rubsh_array="$(set -- $(sha1sum "$BASH_SOURCE"); printf "%s" "$1")"

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

_rubsh.Shell.alias_function Array.== Array.eql?

Array.eql? () {
  local _array1="$1"
  local _array2="$2"
  local i

  _rubsh.Shell.dereference _array1
  _rubsh.Shell.dereference _array2
  [[ ${#_array1[@]} -eq ${#_array2[@]} ]] || return 1
  for i in "${!_array1[@]}"; do
  [[ ${_array1["$i"]} == "${_array2["$i"]}" ]] || return 1
  done
}

# https://stackoverflow.com/questions/3685970/check-if-an-array-contains-a-value#answer-8574392
Array.include? () {
  local elem
  local array

  array=( $(_rubsh.Shell.value "$1") )
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

  array=( $( _rubsh.Shell.value "$1") )
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

  ! _rubsh.Shell.variable? "$delim" || _rubsh.Shell.dereference delim
  # shellcheck disable=SC2046
  set -- $(_rubsh.Shell.value "$1")
  printf "%s" "$1"
  shift
  printf "%s" "${@/#/$delim}"
}

Array.new() {
  local _rubsh_arg
  local _rubsh_method
  local _rubsh_methods
  local _rubsh_val

  # shellcheck disable=SC2034
  read -d "" -a _rubsh_methods <<EOS
==
eql?
include?
index
join
remove
slice
to_s
EOS

  for _rubsh_method in "${_rubsh_methods[@]}"; do
    _rubsh.core.alias_method "$1" "$_rubsh_method" "Array"
  done

  (( ${#@} > 1 )) || return 0
  local "$1" && {
    _rubsh_arg="$1"
    shift
    (( ${#@} > 1 )) || {
      eval "_rubsh_val=$1"
      _rubsh.Shell.passback_as "$_rubsh_arg" "${_rubsh_val[@]}"
      return 0
    }
    _rubsh.Shell.passback_as "$_rubsh_arg" "$@"
  }
}

Array.remove() {
  local i
  local item
  local result

  item="$2"
  # shellcheck disable=SC2046
  set -- $(_rubsh.Shell.value "$1")
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
