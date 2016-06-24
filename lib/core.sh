#!/usr/bin/env bash
# Core functions used by other modules

[[ -z $_rubsh_core ]] || return 0

# shellcheck disable=SC2046,SC2155
declare -r _rubsh_core="$(set -- $(sha1sum "$BASH_SOURCE"); printf "%s" "$1")"

_rubsh_core.source_location() {
  local dir

  if [[ -d $1 ]]; then
    dir="$1"
  else
    dir="$PWD"
  fi
  printf "%s" "$dir"
}

_rubsh_core.abspath() { pushd "$1" >/dev/null && pwd; popd >/dev/null; }

# https://stackoverflow.com/questions/192292/bash-how-best-to-include-other-scripts/12694189#12694189
# shellcheck disable=SC2155
[[ -n $_rubsh_lib ]]  || declare -r _rubsh_lib="$(_rubsh_core.abspath "$(_rubsh_core.source_location "${BASH_SOURCE%/*}")")"

# https://stackoverflow.com/questions/10582763/how-to-return-an-array-in-bash-without-using-globals/15982208#15982208
# Print array definition to use with assignments, for loops, etc.
#   varname: the name of an array variable.
_Array.to_s() {
    local r

    r=$( declare -p $1 )
    r=${r#declare\ -a\ *=}
    # Strip keys so printed definition will be a simple list (like when using
    # "${array[@]}").  One side effect of having keys in the definition is
    # that when appending arrays (i.e. `a1+=$( my_a.to_s a2 )`), values at
    # matching indices merge instead of pushing all items onto array.
    r=${r//\[[0-9]\]=}
    printf "%s" "${r:1:-1}"
}

# Same as ary.use() but preserves keys.
_rubsh_core.alias_core() {
  local alias

  for alias in $(_sh.value "$2"); do
    _sh.alias_function "$1.$alias" "_$1.$alias"
  done
}

_rubsh_core.alias_method() {
  eval "$1.$2 () { $3.$2 $1 \"\$@\" ;}"
}

_Hash.to_s() {
    local r

    r=$( declare -p $1 )
    printf "%s" "${r#declare\ -a\ *=}"
}


_sh.alias_function() { eval "$1 () { $2 \"\$@\" ;}" ;}

_sh.class() {
  case "$(declare -p $1)" in
    declare\ -a* )
      printf "array"
      ;;
    * )
      printf "string"
      ;;
  esac
}

_sh.deref() {
  set -- "$1" "$(_sh.value "$1")"

  case "$(_sh.class "$2")" in
    "string" )
      # shellcheck disable=SC2046
      local "$1" && _sh.upvar "$1" "$(_sh.value "$2")"
      ;;
    "array" )
      # shellcheck disable=SC2046
      local "$1" && _sh.upvar "$1" $(_sh.value "$2")
      ;;
  esac
}

_sh.strict_mode() {
  case "$1" in
    on )
      set -o errexit
      set -o nounset
      set -o pipefail
      ;;
    off )
      set +o errexit
      set +o nounset
      set +o pipefail
      ;;
  esac
}

_sh.trace() {
  case "$1" in
    "on" )
      set -o xtrace
      ;;
    "off" )
      set +o xtrace
      ;;
  esac
}

# Assign variable one scope above the caller
# Usage: local "$1" && _sh.upvar $1 "value(s)"
# Param: $1  Variable name to assign value to
# Param: $*  Value(s) to assign.  If multiple values, an array is
#            assigned, otherwise a single value is assigned.
# NOTE: For assigning multiple variables, use 'upvars'.  Do NOT
#       use multiple 'upvar' calls, since one 'upvar' call might
#       reassign a variable to be used by another 'upvar' call.
# See: http://fvue.nl/wiki/Bash:_Passing_variables_by_reference
_sh.upvar() {
    if unset -v "$1"; then           # Unset & validate varname
        if (( $# == 2 )); then
            eval "$1"=\"\$2\"          # Return single value
        else
            eval "$1"=\(\"\${@:2}\"\)  # Return array
        fi
    fi
}

# Assign variables one scope above the caller
# Usage: local varname [varname ...] &&
#        _sh.upvars [-v varname value] | [-aN varname [value ...]] ...
# Available OPTIONS:
#     -aN  Assign next N values to varname as array
#     -v   Assign single value to varname
# Return: 1 if error occurs
_sh.upvars() {
    if ! (( $# )); then
        echo "${FUNCNAME[0]}: usage: ${FUNCNAME[0]} [-v varname"\
            "value] | [-aN varname [value ...]] ..." 1>&2
        return 2
    fi
    while (( $# )); do
        case $1 in
            -a*)
                # Error checking
                [[ ${1#-a} ]] || { echo "bash: ${FUNCNAME[0]}: \`$1': missing"\
                    "number specifier" 1>&2; return 1; }
                printf %d "${1#-a}" &> /dev/null || { echo "bash:"\
                    "${FUNCNAME[0]}: \`$1': invalid number specifier" 1>&2
                    return 1; }
                # Assign array of -aN elements
                [[ "$2" ]] && unset -v "$2" && eval "$2"=\(\"\${@:3:${1#-a}}\"\) &&
                shift $((${1#-a} + 2)) || { echo "bash: ${FUNCNAME[0]}:"\
                    "\`$1${2+ }$2': missing argument(s)" 1>&2; return 1; }
                ;;
            -v)
                # Assign single value
                [[ "$2" ]] && unset -v "$2" && eval "$2"=\"\$3\" &&
                shift 3 || { echo "bash: ${FUNCNAME[0]}: $1: missing"\
                "argument(s)" 1>&2; return 1; }
                ;;
            --help) echo "\
Usage: local varname [varname ...] &&
   ${FUNCNAME[0]} [-v varname value] | [-aN varname [value ...]] ...
Available OPTIONS:
-aN VARNAME [value ...]   assign next N values to varname as array
-v VARNAME value          assign single value to varname
--help                    display this help and exit
--version                 output version information and exit"
                return 0 ;;
            --version) echo "\
${FUNCNAME[0]}-0.9.dev
Copyright (C) 2010 Freddy Vulto
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law."
                return 0 ;;
            *)
                echo "bash: ${FUNCNAME[0]}: $1: invalid option" 1>&2
                return 1 ;;
        esac
    done
}

_sh.value()     {
  case "$(_sh.class "$1")" in
    "array" )
      eval printf \"%s \" \"\$\{"$1"[@]\}\"
      ;;
    * )
      eval printf \"%s\" \"\$"$1"\"
      ;;
  esac
}

_String.blank? ()  { eval "[[ -z \${$1:-} ]] || [[ \${$1:-} =~ ^[[:space:]]+$ ]]"  ;}
_String.eql? ()    { eval "[[ \${$1:-} == \"$2\" ]]" ;}

_String.new() {
  local _rubsh_method
  local _rubsh_methods

  # shellcheck disable=SC2034
  read -d "" -a _rubsh_methods <<EOS
blank?
eql?
present?
EOS

  for _rubsh_method in "${_rubsh_methods[@]}"; do
    _rubsh_core.alias_method "$1" "$_rubsh_method" "_String"
  done

  [[ ${#@} -gt 1 ]] || return 0

  local "$1" && _sh.upvar "$1" "$2"
}

_String.present? () { ! _String.blank? "$@" ;}

_rubsh_core.require() {
  local path="$PATH"

  export PATH="$RUBSH_PATH${RUBSH_PATH:+:}$PATH"
  source "$1".sh 2>/dev/null || source "$1"
  export PATH="$path"
}
