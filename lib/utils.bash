class () {
  __class=$1 # not local
  local super=${3-String}
  local statement

  [[ -z ${2-}  || $2 == ':' ]] || return
  [[ -n $super ]] && {
    ! declare -f "$__class" >/dev/null 2>&1 || return
      declare -f "$super"   >/dev/null 2>&1 || return
    __superh[$__class]=$super
  }
  printf -v statement 'function %s { __dispatch "$@" ;}' "$__class"
  eval "$statement"
  __classh[$__class]=Class
  __methodsh[$__class]=' '
  __='""'
  __classh[__]=String
}

__clear_vars () {
  local -n __vars=$1

  unset -v "${__vars[@]}"
}

__declare_hashes () {
  local -n __vars=$1
  local __var

  for __var in "${__vars[@]}"; do
    [[ $__var == *h ]] && declare -Ag "$__var"
  done
}

def () {
  local method=$1
  local body=${2-$(</dev/stdin)}

  __methodsh[$__class]+="$method "
  [[ -z ${__method_classesh[$method]-} ]] && __method_classesh[$method]=' '
  __method_classesh[$method]+="$__class "
  __method_bodyh[$__class.$method]=$body
  __='""'
  __classh[__]=String
}

__dispatch () {
  local method=${1-.inspect}; shift ||:
  local receiver=${FUNCNAME[1]}
  local class=${__classh[$receiver]}
  local i
  local rest=()
  local statement

  [[ $method != '.'* ]] && {
    case $method in
      '=' ) method=.=;;
      *   )
        case ${1-} in
          '='   ) set -- "$method" "${@:2}"; method=.new     ;;
          ':='  ) set -- "$method" "${@:2}"; method=.declare ;;
          * )
            [[ $class == 'Class' ]] || return
            $("$receiver" .declare anon "$method")
            anon "$@"
            return
            ;;
          * ) return 1;;
        esac
        ;;
    esac
  }
  method=${method#.}
  while [[ ${__method_classesh[$method]} != *" $class "* ]]; do
    [[ -n ${__superh[$class]-} ]] || return
    class=${__superh[$class]}
  done
  [[ -n ${__method_bodyh[$class.$method]-} ]] || return
  [[ ${1-} == '{' ]] && {
    for (( i = 1; i <= $#; i++ )); do
      [[ ${!i} == '}' ]] && break;
    done
    [[ ${!i} == '}' ]] || return
    rest=( "${@:i+1}" )
    set -- "${@:2:i-2}"
  }
  printf -v statement 'function __ { %s ;}; __ "$receiver" "$@"' "${__method_bodyh[$class.$method]}"
  eval "$statement"
  ! (( ${#rest[@]} )) && return
  "${__classh[__]}" "$__" "${rest[@]}"
}

__glob () {
  case $1 in
    'on'  ) set +f;;
    'off' ) set -f;;
    *     ) return 1;;
  esac
}

initialize_rubsh () {
  export RUBSH_PATH+=${RUBSH_PATH:+:}$(unset -v CDPATH; cd "$(dirname $BASH_SOURCE)"; pwd)
  __glob off

  vars=(
    __
    __class
    __classh
    __features
    __method_bodyh
    __method_classesh
    __methodsh
    __superh
  )
  __clear_vars      vars
  __declare_hashes  vars
}

__inspect () {
  __=$(declare -p "$1" 2>/dev/null) || return
  __=${__#*=}
  __=${__#\'}
  __=${__%\'}
}

package () {
  local package_name=$1
  local IFS
  local statements=()

  IFS=$'\n' read -rd '' -a statements <<'  EOS' ||:
    [[ -n ${_%s-} && -z ${reload-}  ]] && return
    [[ -n ${reload-}                ]] && { unset -v reload && echo reloaded || return ;}
    [[ -z ${_%s-}                   ]] && readonly _%s=loaded
  EOS
  IFS=';'
  printf "eval ${statements[*]}\n" "$package_name" "$package_name" "$package_name"
}

puts () {
  { declare -f "$1" >/dev/null 2>&1 && [[ " ${!__classh[*]} " == *" $1 "* ]] ;} && {
    (( $# == 1 )) && { "$1" .to_s; printf '%s\n' "$__"; return ;}
    "$@"
    printf '%s\n' "$__"
    return
  }
  printf '%s\n' "$@"
  __='""'
  __classh[__]=String
}

require () {
  local feature_name=$1
  local path

  [[ " ${__features[*]-} " == *" $feature_name "* ]] && return
  path=$PATH
  PATH=${RUBSH_PATH-}${RUBSH_PATH:+:}.
  source "$feature_name"          2>/dev/null ||
    source "$feature_name".rubsh  2>/dev/null ||
    source "$feature_name".bash   2>/dev/null ||
    source "$feature_name".sh     2>/dev/null
  feature_name=${feature_name##*/}
  feature_name=${feature_name%.*}
  __features+=( $feature_name )
  PATH=$path
}
