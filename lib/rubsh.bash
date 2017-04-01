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
  __=''
}

def () {
  local method=$1
  local body=${2-$(</dev/stdin)}

  __methodsh[$__class]+="$method "
  [[ -z ${__method_classesh[$method]-} ]] && __method_classesh[$method]=' '
  __method_classesh[$method]+="$__class "
  __method_bodyh[$__class.$method]=$body
  __=''
}

class Object : ''; {
  def class '__=${__classh[$1]}'

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
    __ary_to_str methods
  end

  def set <<'  end'
    local -n __self=$1; shift

    __=''
    "$@"
    eval __self="$__"
  end

  def to_s <<'  end'
    __=$(declare -p "$1" 2>/dev/null) || return
    __=${__#*=}
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
    __ary_to_str ancestors
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
    __ary_to_str instance_methods
  end

  def new <<'  end'
    local class=$1
    local self=$2
    local value=${3-}
    local statement
    local statement2

    ! declare -f "$self" >/dev/null || return
    printf -v statement 'function %s { __dispatch "$@" ;}' "$self"
    eval "$statement"
    [[ $class == 'Class' ]] && __superh[$self]=Object
    __classh[$self]=$class
    __=''
  end

  def superclass <<'  end'
    local class=$1

    __=${__superh[$class]-}
  end
}

class Array; {
  def append <<'  end'
    local -n __vals=$1; shift
    local __results=()
    local __statement

    case $# in
      '0' ) return;;
      '1' )
        printf -v __statement '__vals+=( "${%s[@]}" )' "$1"
        eval "$__statement"
        ;;
      * )
        "$@"
        eval __results="$__"
        __vals+=( "${__results[@]}" );;
    esac
  end

  def join <<'  end'
    local -n __vals=$1
    local IFS=${1- }

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
    local __lambda=$5
    local "$__keyparm"
    local "$__valparm"
    local __key
    local __retvals=()
    local __statement

    printf -v __statement '__retvals+=( "$(puts "%s")" )' "$__lambda"

    for __key in "${!__valh[@]}"; do
      printf -v "$__keyparm" '%s' "$__key"
      printf -v "$__valparm" '%s' "${__valh[$__key]}"
      eval "$__statement"
    done

    __ary_to_str __retvals
  end

  def to_s <<'  end'
    __=$(declare -p "$1" 2>/dev/null) || return
    __=${__#*=}
    __=${__:1:-1}
  end
}

class String

puts () { local IFS=''; printf '%s\n' "$*" ;}

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

__ary_to_str () {
  __=$(declare -p "$1" 2>/dev/null) || return
  __=${__#*=}
  __=${__:1:-1}
}

__dispatch () {
  local method=${1-.to_s}; shift
  local receiver=${FUNCNAME[1]}
  local class=${__classh[$receiver]}
  local statement

  [[ $method == '.'* ]] || return
  method=${method#.}
  while [[ ${__method_classesh[$method]} != *" $class "* ]]; do
    [[ -n ${__superh[$class]-} ]] || return
    class=${__superh[$class]}
  done
  [[ -n ${__method_bodyh[$class.$method]-} ]] || return
  printf -v statement 'function __ { %s ;}; __ "$receiver" "$@"' "${__method_bodyh[$class.$method]}"
  eval "$statement"
}
