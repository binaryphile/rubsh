#!/usr/bin/env bash
# Functions for string testing and manipulation

[[ -z $_rubsh_string ]] || return 0

# shellcheck disable=SC2046
readonly _rubsh_string="$(set -- $(sha1sum "$BASH_SOURCE"); printf "%s" "$1")"

source "${BASH_SOURCE%/*}"/core.sh 2>/dev/null || source core.sh

_rubsh_init() {
  local aliases

  # shellcheck disable=SC2034
  read -d "" -a aliases <<EOS
blank?
chomp
end_with?
eql?
start_with?
EOS

  _rubsh.core.alias String aliases
}

_rubsh_init
unset -f _rubsh_init

String.class() {
  printf "String"
}

String.new() {
  local method
  local methods

  # shellcheck disable=SC2034
  read -d "" -a methods <<EOS
blank?
class
chomp
end_with?
eql?
split
start_with?
EOS

  for method in "${methods[@]}"; do
    _rubsh.core.alias_method "$1" "$method" "String"
  done

  (( ${#@} > 1 )) || return 0

  local "$1" && _rubsh.Shell.passback_as "$1" "$2"
}

String.split() {
  local array
  local delimiter="$2"

  ! _rubsh.Shell.variable? "$delimiter" || _rubsh.Shell.dereference delimiter
  if [[ -z $delimiter ]]; then
    read -ra array <<< "$(_rubsh.sh.value "$1")"
  else
    IFS="$2" read -ra array <<< "$(_rubsh.sh.value "$1")"
  fi
  cat <<< "${array[@]}"
}
