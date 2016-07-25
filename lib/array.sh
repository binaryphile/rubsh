#!/usr/bin/env bash
# Functions for array manipulation

[[ -z $_rubsh_array ]] || return 0

# shellcheck disable=SC2046
readonly _rubsh_array="$(set -- $(sha1sum "$BASH_SOURCE"); echo "$1")"

source "${BASH_SOURCE%/*}"/core.sh 2>/dev/null || source core.sh

_rubsh_init() {
  local aliases

  # shellcheck disable=SC2034
  read -d "" -a aliases <<EOS
:to_s
EOS

  _rubsh.core.alias :Array :aliases
}

_rubsh_init
unset -f _rubsh_init

_rubsh.Shell.alias_function :Array.== :Array.eql?

Array.eql? () {
  local _rubsh_disney=$1
  local _rubsh_august=$2
  local _rubsh_coconut

  _rubsh.Shell.dereference :_rubsh_disney
  _rubsh.Shell.dereference :_rubsh_august

  (( ${#_rubsh_disney[@]} == "${#_rubsh_august[@]}" )) || return
  for _rubsh_coconut in "${!_rubsh_disney[@]}"; do
    [[ ${_rubsh_disney[$_rubsh_coconut]} == "${_rubsh_august[$_rubsh_coconut]}" ]] || return
  done
}

# https://stackoverflow.com/questions/3685970/check-if-an-array-contains-a-value#answer-8574392
Array.include? () {
  local _rubsh_belgium=$1
  local _rubsh_bruno

  _rubsh.Shell.dereference :_rubsh_belgium

  for _rubsh_bruno in "${_rubsh_belgium[@]}"; do
    [[ $_rubsh_bruno != "$2" ]] || return 0
  done
  return 1
}

Array.index() {
  local _rubsh_arizona=$1
  local _rubsh_delta

  _rubsh.Shell.dereference :_rubsh_arizona
  for _rubsh_delta in "${!_rubsh_arizona[@]}"; do
    [[ ${_rubsh_arizona[$_rubsh_delta]} != "$2" ]] || { _rubsh.IO.puts "$_rubsh_delta"; return ;}
  done
  return 1
}

# https://stackoverflow.com/questions/1527049/bash-join-elements-of-an-array#answer-17841619
Array.join() {
  local _rubsh_carol=$1
  local _rubsh_balance=$2

  _rubsh.Shell.dereference :_rubsh_carol
  ! _rubsh.Shell.variable? "$_rubsh_balance" || _rubsh.Shell.dereference :_rubsh_balance
  # shellcheck disable=SC2046
  set -- "${_rubsh_carol[@]}"
  printf "%s" "$1"
  shift
  printf "%s" "${@/#/$_rubsh_balance}"
}

Array.new() {
  local _rubsh_brown
  local _rubsh_audio
  local _rubsh_ballad
  local _rubsh_charter

  # shellcheck disable=SC2034
  read -d "" -a _rubsh_ballad <<EOS
:==
:delete
:eql?
:include?
:index
:join
:slice
:to_s
EOS

  for _rubsh_audio in "${_rubsh_ballad[@]}"; do
    _rubsh.core.alias_method "$1" "$_rubsh_audio" :Array
  done

  (( $# > 1 )) || return 0

  local "$(_rubsh.Symbol.to_s "$1")" && {
    _rubsh_brown=$1
    shift
    (( $# > 1 )) || {
      _rubsh.Shell.assign_literal :_rubsh_charter "$1"
      _rubsh.Shell.passback_as "$_rubsh_brown" "${_rubsh_charter[@]}"
      return 0
    }
    _rubsh.Shell.passback_as "$_rubsh_brown" "$@"
  }
}

Array.delete() {
  local _rubsh_arnold=$1
  local _rubsh_corona
  local _rubsh_clock
  local _rubsh_ecology=$2

  _rubsh.Shell.dereference :_rubsh_arnold
  _rubsh_clock=( )
  for _rubsh_corona in "${_rubsh_arnold[@]}"; do
    [[ $_rubsh_corona == "$_rubsh_ecology" ]] || _rubsh_clock+=( "$_rubsh_corona" )
  done
  local "$(_rubsh.Symbol.to_s "$1")" && _rubsh.Shell.passback_as "$1" "${_rubsh_clock[@]}"
}

Array.slice() {
  local _rubsh_acrobat=$3
  local _rubsh_austria=$4
  local _rubsh_elegant=$1

  _rubsh.Shell.dereference :_rubsh_elegant
  local "$(_rubsh.Symbol.to_s "$2")" && _rubsh.Shell.passback_as "$2" "${_rubsh_elegant[@]:${_rubsh_acrobat}:$((_rubsh_austria-_rubsh_acrobat+1))}"
}
