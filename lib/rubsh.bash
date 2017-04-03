[[ -n ${_rubsh-} && -z ${reload-} ]] && return
[[ -n ${reload-}                  ]] && { unset -v reload && echo reloaded || return ;}
[[ -z ${_rubsh-}                  ]] && readonly _rubsh=loaded

unset   -v  __classh __method_classesh __methodsh __method_bodyh __superh __ __class
declare -Ag __classh __method_classesh __methodsh __method_bodyh __superh

class () {
  __class=$1 # global
  local super=${3-Object}
  local statement

  [[ -z ${2-}  || $2 == ':' ]] || return
  [[ -n $super ]] && {
    ! declare -f "$__class" >/dev/null || return
      declare -f "$super"   >/dev/null || return
    __superh[$__class]=$super
  }
  printf -v statement 'function %s { __dispatch "$@" ;}' "$__class"
  eval "$statement"
  __classh[$__class]=Class
  __methodsh[$__class]=' '
  __='""'
}

def () {
  local method=$1
  local body=${2-$(</dev/stdin)}

  __methodsh[$__class]+="$method "
  [[ -z ${__method_classesh[$method]-} ]] && __method_classesh[$method]=' '
  __method_classesh[$method]+="$__class "
  __method_bodyh[$__class.$method]=$body
  __='""'
}

class Object : ''; {
  def class << '  end'
    __=${__classh[$1]}
    __=$(declare -p __)
    __=${__#*=}
  end

  def methods <<'  end'
    local self=$1
    local inherited=${2-true}
    local class=${__classh[$self]}
    local methods=()

    case $inherited in
      'false' ) ;;
      'true'  )
        methods=( ${__methodsh[$class]} )
        while [[ -n ${__superh[$class]-} ]]; do
          class=${__superh[$class]}
          methods+=( ${__methodsh[$class]} )
        done
        ;;
      * ) return 1;;
    esac
    __to_str methods
  end

  def set <<'  end'
    local -n __self=$1; shift

    unset -v __
    "$@"
    eval __self="$__"
  end

  def to_s <<'  end'
    __=$(declare -p "$1" 2>/dev/null) || return
    __=${__#*=}
    __=${__:1:-1}
  end
}

class Class; {
  def ancestors <<'  end'
    local class=$1
    local ancestors=( $class )

    while [[ -n ${__superh[$class]-} ]]; do
      class=${__superh[$class]}
      ancestors+=( "$class" )
    done
    __to_str ancestors
  end

  def declare <<'  end'
    local class=$1
    local self=$2
    local value=${3-}
    local format

    ! declare -f "$self" >/dev/null || return
    value=$(declare -p value)
    value=${value#*=}
    case $class in
      'Array' ) printf 'eval declare -a %s=%s; %s .new %s\n' "$self" "${value:1:-1}" "$class" "$self" ;;
      'Hash'  ) printf 'eval declare -A %s=%s; %s .new %s\n' "$self" "${value:1:-1}" "$class" "$self" ;;
      *       ) printf 'eval declare -- %s=%s; %s .new %s\n' "$self" "$value"        "$class" "$self" ;;
    esac
    __=$value
  end

  def instance_methods <<'  end'
    local class=$1
    local inherited=${2-true}
    local instance_methods=( ${__methodsh[$class]} )

    case $inherited in
      'false' ) ;;
      'true'  )
        while [[ -n ${__superh[$class]-} ]]; do
          class=${__superh[$class]}
          instance_methods+=( ${__methodsh[$class]} )
        done
        ;;
      * ) return 1;;
    esac
    __to_str instance_methods
  end

  def new <<'  end'
    local class=$1
    local self=$2
    local value=${3-}
    local format
    local stdout
    local statement

    ! declare -f "$self" >/dev/null || return
    printf -v statement 'function %s { __dispatch "$@" ;}' "$self"
    eval "$statement"
    [[ $class == 'Class' ]] && __superh[$self]=Object
    __classh[$self]=$class
    [[ -n $value ]] && {
      case $value in
        '('* ) format='%s=%s';;
           * ) format='%s=%q';;
      esac
      printf -v statement "$format" "$self" "$value"
      eval "$statement"
    }
    __=$value
  end

  def superclass <<'  end'
    local class=$1

    __=${__superh[$class]-}
  end
}

class Array; {
  def concat <<'  end'
    local -n __vals=$1; shift
    local __results=()
    local __statement

    "$@"
    eval __results="$__"
    __vals+=( "${__results[@]}" )
    __to_str __vals
    __=${__:1:-1}
    __to_str "$__"
  end

  def join <<'  end'
    local -n __vals=$1
    local IFS=${2- }

    __=${__vals[*]}
  end

  def to_s <<'  end'
    __=$(declare -p "$1" 2>/dev/null) || return
    __=${__#*=}
    __=${__:1:-1}
  end
}

class Hash; {
  def map <<'  end'
    local -n __valh=$1
    local __keyparm=$3
    local __valparm=$4
    local __lambda=${5-$(</dev/stdin)}
    local "$__keyparm"
    local "$__valparm"
    local __key
    local __retvals=()
    local __statement

    [[ $2 == 'do' ]] && __lambda=${__lambda#${__lambda%%[![:space:]]*}}
    printf -v __statement '__retvals+=( "$(puts "%s")" )' "$__lambda"

    for __key in "${!__valh[@]}"; do
      printf -v "$__keyparm" '%s' "$__key"
      printf -v "$__valparm" '%s' "${__valh[$__key]}"
      eval "$__statement"
    done

    __to_str __retvals
  end

  def to_s <<'  end'
    __=$(declare -p "$1" 2>/dev/null) || return
    __=${__#*=}
    __=${__:1:-1}
  end
}

class String

puts () {
  { declare -f "$1" >/dev/null && [[ " ${!__classh[*]} " == *" $1 "* ]] ;} && {
    "$@" || return
    printf '%s\n' "$__"
    return
  }
  printf '%s\n' "$@"
  __="''"
}

class Path : String; {
  def expand_path <<'  end'
    local __pathname=${!1}
    local __filename

    unset -v CDPATH
    [[ -e $__pathname ]] && {
      __filename=$(basename "$__pathname")
      __pathname=$(dirname "$__pathname")
    }
    [[ -d $__pathname ]] || return
    __pathname=$(cd "$__pathname"; pwd)
    __=$__pathname${__filename:+/}${__filename-}
  end
}

class File : Path; {
  def each <<'  end'
    local __filename=${!1}
    local __lineparm=$3
    local __lambda=${4-$(</dev/stdin)}
    local "$__lineparm"

    while read -r "$__lineparm"; do
      eval "$__lambda"
    done <"$__filename" ||:
  end

  def readlines <<'  end'
    local __filename=${!1}; shift
    local __lines=()

    IFS=$'\n' read -rd '' -a __lines <"$__filename"
    __to_str __lines
  end

  def write <<'  end'
    local __filename=${!1}; shift
    local __string

    case $# in
      '0' ) return              ;;
      '1' ) __string=${!1}      ;;
      *   ) "$@"; __string=$__  ;;
    esac
    puts "$__string" >"$__filename"
  end
}

__to_str () {
  __=$(declare -p "$1" 2>/dev/null) || return
  __=${__#*=}
  if [[ $__ == \'* ]]; then __=${__:1:-1}; fi
}

__dispatch () {
  local method=${1-.to_s}; shift ||:
  local receiver=${FUNCNAME[1]}
  local class=${__classh[$receiver]}
  local statement

  [[ $method != '.'* ]] && {
    case $1 in
      '=' )
        set -- "$method" "${@:2}"
        method=.new
        ;;
      '=^' )
        set -- "$method" "${@:2}"
        method=.declare
        ;;
      * ) return 1;;
    esac
  }
  method=${method#.}
  while [[ ${__method_classesh[$method]} != *" $class "* ]]; do
    [[ -n ${__superh[$class]-} ]] || return
    class=${__superh[$class]}
  done
  [[ -n ${__method_bodyh[$class.$method]-} ]] || return
  printf -v statement 'function __ { %s ;}; __ "$receiver" "$@"' "${__method_bodyh[$class.$method]}"
  eval "$statement"
}
