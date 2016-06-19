#!/usr/bin/env bash
# Functions for string testing and manipulation

# https://stackoverflow.com/questions/192292/bash-how-best-to-include-other-scripts/12694189#12694189
[[ -n $_rubsh_lib ]] || {
  if [[ -d ${BASH_SOURCE%/*} ]]; then
    declare -r _rubsh_lib="${BASH_SOURCE%/*}"
  else
    declare -r _rubsh_lib="$PWD"
  fi
}

[[ -z $_rubsh_string ]] || return 0
# shellcheck disable=SC2046,SC2155
declare -r _rubsh_string="$(set -- $(sha1sum "${BASH_SOURCE}"); printf "%s" "$1")"

source "$_rubsh_lib"/core.sh

_rubsh_init() {
  local aliases

  # shellcheck disable=SC2034
  read -d "" -a aliases <<EOS
blank?
eql?
EOS

  _core.alias_core String aliases
}

_rubsh_init
unset -f _rubsh_init

String.split() {
  local array

  IFS="$2" read -ra array <<< "$(_sh.value "$1")"
  cat <<< "${array[@]}"
}

String.exit_if_blank? ()  { ! String.blank? "$1" || exit "${2:-0}" ;}

String.new() {
  local method
  local methods

  # shellcheck disable=SC2034
  read -d "" -a methods <<EOS
blank?
eql?
split
exit_if_blank?
EOS

  for method in "${methods[@]}"; do
    _core.alias_method "$1" "$method" "String"
  done

  [[ ${#@} -gt 1 ]] || return 0

  local "$1" && _sh.upvar "$1" "$2"
}
