#!/usr/bin/env bash
# Functions for array manipulation

[[ -z $_rubsh_array ]] || return 0

# shellcheck disable=SC2046
readonly _rubsh_array=$(set -- $(sha1sum "$BASH_SOURCE"); echo "$1")

source "${BASH_SOURCE%/*}"/core.sh 2>/dev/null || source core.sh

_rubsh_init() {
  local aliases

  # shellcheck disable=SC2034
  read -d "" -a aliases <<EOS
:to_s
:inspect
EOS

  _rubsh.core.alias :Array :aliases
}

_rubsh_init
unset -f _rubsh_init

_rubsh.Shell.alias_function :Array.== :Array.eql?

Array.eql? () {
  local _rubsh_aeq_array1=$1
  local _rubsh_aeq_array2=$2
  local _rubsh_aeq_i

  _rubsh.Shell.dereference :_rubsh_aeq_array1
  _rubsh.Shell.dereference :_rubsh_aeq_array2

  (( ${#_rubsh_aeq_array1[@]} == "${#_rubsh_aeq_array2[@]}" )) || return
  for _rubsh_aeq_i in "${!_rubsh_aeq_array1[@]}"; do
    [[ ${_rubsh_aeq_array1[$_rubsh_aeq_i]} == "${_rubsh_aeq_array2[$_rubsh_aeq_i]}" ]] || return
  done
}

# https://stackoverflow.com/questions/3685970/check-if-an-array-contains-a-value#answer-8574392
Array.include? () {
  local _rubsh_ain_array=$1
  local _rubsh_ain_item

  _rubsh.Shell.dereference :_rubsh_ain_array

  for _rubsh_ain_item in "${_rubsh_ain_array[@]}"; do
    [[ $_rubsh_ain_item != "$2" ]] || return 0
  done
  return 1
}

Array.index() {
  local _rubsh_aix_array=$1
  local _rubsh_aix_i

  _rubsh.Shell.dereference :_rubsh_aix_array
  for _rubsh_aix_i in "${!_rubsh_aix_array[@]}"; do
    [[ ${_rubsh_aix_array[$_rubsh_aix_i]} != "$2" ]] || {
      _rubsh.IO.puts "$_rubsh_aix_i"
      return
    }
  done
  return 1
}

# https://stackoverflow.com/questions/1527049/bash-join-elements-of-an-array#answer-17841619
Array.join() {
  local _rubsh_ajo_array=$1
  local _rubsh_ajo_delimiter=$2

  _rubsh.Shell.dereference :_rubsh_ajo_array
  ! _rubsh.Shell.variable? "$_rubsh_ajo_delimiter" || _rubsh.Shell.dereference :_rubsh_ajo_delimiter
  set -- "${_rubsh_ajo_array[@]}"
  printf "%s" "$1"
  shift
  printf "%s" "${@/#/$_rubsh_ajo_delimiter}"
}

Array.new() {
  local _rubsh_ane_initializer
  local _rubsh_ane_method
  local _rubsh_ane_methods
  local _rubsh_ane_return_ref

  # shellcheck disable=SC2034
  read -d "" -a _rubsh_ane_methods <<EOS
:==
:delete
:eql?
:include?
:index
:join
:slice
:to_s
EOS

  for _rubsh_ane_method in "${_rubsh_ane_methods[@]}"; do
    _rubsh.core.alias_method "$1" "$_rubsh_ane_method" :Array
  done

  (( $# > 1 )) || return 0

  local "$(_rubsh.Symbol.to_s "$1")"
  _rubsh_ane_return_ref=$1
  shift
  (( $# > 1 )) || {
    _rubsh.Shell.assign_literal :_rubsh_ane_initializer "$1"
    _rubsh.Shell.passback_as "$_rubsh_ane_return_ref" "${_rubsh_ane_initializer[@]}"
    return 0
  }
  _rubsh.Shell.passback_as "$_rubsh_ane_return_ref" "$@"
}

Array.delete() {
  local _rubsh_ade_array=$1
  local _rubsh_ade_item
  local _rubsh_ade_result
  local _rubsh_ade_target=$2

  _rubsh.Shell.dereference :_rubsh_ade_array
  _rubsh_ade_result=( )
  for _rubsh_ade_item in "${_rubsh_ade_array[@]}"; do
    [[ $_rubsh_ade_item == "$_rubsh_ade_target" ]] || _rubsh_ade_result+=( "$_rubsh_ade_item" )
  done
  local "$(_rubsh.Symbol.to_s "$1")" && _rubsh.Shell.passback_as "$1" "${_rubsh_ade_result[@]}"
}

Array.slice() {
  local _rubsh_asl_start=$3
  local _rubsh_asl_length=$4
  local _rubsh_asl_array=$1

  _rubsh.Shell.dereference :_rubsh_asl_array
  local "$(_rubsh.Symbol.to_s "$2")" && _rubsh.Shell.passback_as "$2" "${_rubsh_asl_array[@]:${_rubsh_asl_start}:$((_rubsh_asl_length-_rubsh_asl_start+1))}"
}
