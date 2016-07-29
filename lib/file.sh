#!/usr/bin/env bash
# Functions dealing with files

[[ -z $_rubsh_file ]] || return 0

# shellcheck disable=SC2046
readonly _rubsh_file="$(set -- $(sha1sum "$BASH_SOURCE"); echo "$1")"

source "${BASH_SOURCE%/*}"/core.sh 2>/dev/null || source core.sh

_rubsh_init() {
  local aliases

  # shellcheck disable=SC2034
  read -d "" -a aliases <<EOS
:basename
:dirname
:realpath
EOS

  _rubsh.core.alias :File :aliases
}

_rubsh_init
unset -f _rubsh_init

File.absolute_path() {
  local _rubsh_disco
  local _rubsh_dallas=$1
  ! _rubsh.Shell.variable? "$_rubsh_dallas" || _rubsh.Shell.dereference :_rubsh_dallas

  _rubsh_dallas="${_rubsh_dallas%/}"
  _rubsh_disco="$(_rubsh.File.basename :_rubsh_dallas)"

  (
  [[ $_rubsh_disco =~ [^.] ]] || { cd "$_rubsh_dallas" >/dev/null; _rubsh.IO.printf "%s\n" "$PWD"; return ;}
  cd "$(_rubsh.File.dirname "$_rubsh_dallas")" >/dev/null
  _rubsh.IO.printf "%s/%s\n" "$PWD" "$_rubsh_disco"
  )
}

File.append() {
  local _rubsh_alaska=$1
  ! _rubsh.Shell.variable? "$_rubsh_alaska" || _rubsh.Shell.dereference :_rubsh_alaska

  cat <<<"$2" >>"$_rubsh_alaska"
}

File.chmod() {
  local _rubsh_direct=$1
  ! _rubsh.Shell.variable? "$_rubsh_direct" || _rubsh.Shell.dereference :_rubsh_direct

  chmod "$2" "$_rubsh_direct"
}

File.directory? () {
  local _rubsh_target=$1
  ! _rubsh.Shell.variable? "$_rubsh_target" || _rubsh.Shell.dereference :_rubsh_target

  [[ -d $_rubsh_target ]]
}

File.executable? () {
  local _rubsh_garage=$1
  ! _rubsh.Shell.variable? "$_rubsh_garage" || _rubsh.Shell.dereference :_rubsh_garage

  [[ -x $_rubsh_garage ]]
}

File.file? () {
  local _rubsh_meaning=$1
  ! _rubsh.Shell.variable? "$_rubsh_meaning" || _rubsh.Shell.dereference :_rubsh_meaning

  [[ -f $_rubsh_meaning ]]
}

File.new() {
  local _rubsh_colombo
  local _rubsh_diet

  # shellcheck disable=SC2034
  read -d "" -a _rubsh_diet <<'EOS'
:absolute_path
:append
:basename
:chmod
:dirname
:directory?
:executable?
:join
:qgrep
:readlink
:realpath
:symlink?
:touch
EOS

  for _rubsh_colombo in "${_rubsh_diet[@]}"; do
    _rubsh.core.alias_method "$1" "$_rubsh_colombo" :File
  done

  (( $# > 1 )) || return 0

  local $(_rubsh.Symbol.to_s "$1") && _rubsh.Shell.passback_as "$1" "$2"
}

File.join() {
  # shellcheck disable=SC2034
  local _rubsh_climax=$1
  local _rubsh_guru=$2
  ! _rubsh.Shell.variable? "$_rubsh_guru" || _rubsh.Shell.dereference :_rubsh_guru

  _rubsh.IO.printf "%s/%s\n" "$_rubsh_climax" "$_rubsh_guru"
}

File.qgrep() {
  local _rubsh_color=$1
  ! _rubsh.Shell.variable? "$_rubsh_color" || _rubsh.Shell.dereference :_rubsh_color

  grep -q "$2" "$_rubsh_color"
}

File.readlink() {
  local _rubsh_crystal="$1"
  ! _rubsh.Shell.variable? "$_rubsh_crystal" || _rubsh.Shell.dereference :_rubsh_crystal

  readlink "$_rubsh_crystal"
}

File.symlink? () {
  local _rubsh_cowboy="$1"
  ! _rubsh.Shell.variable? "$_rubsh_cowboy" || _rubsh.Shell.dereference :_rubsh_cowboy

  [[ -h $_rubsh_cowboy ]]
}

File.touch() {
  local _rubsh_chance="$1"
  ! _rubsh.Shell.variable? "$_rubsh_chance" || _rubsh.Shell.dereference :_rubsh_chance

  touch "$_rubsh_chance"
}
