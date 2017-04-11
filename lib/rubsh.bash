source "$(dirname $BASH_SOURCE)"/utils.bash
$(package rubsh)
initialize_rubsh

class Object : ''; {
  def class << '  end'
    __=${__classh[$1]}
    __=$(declare -p __)
    __=${__#*=}
    __classh[__]=String
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
    __inspect methods
    __classh[__]=Array
  end
}

class Class : Object; {
  def ancestors <<'  end'
    local class=$1
    local ancestors=( $class )

    while [[ -n ${__superh[$class]-} ]]; do
      class=${__superh[$class]}
      ancestors+=( "$class" )
    done
    __inspect ancestors
    __classh[__]=Array
  end

  def declare <<'  end'
    local class=$1
    local self=$2; shift 2
    local value=${1-}
    local format

    value=$(declare -p value)
    value=${value#*=}
    case $class in
      'Array' ) printf 'eval declare -a %s=%s; %s .new %s\n' "$self" "${value:1:-1}" "$class" "$self" ;;
      'Hash'  ) printf 'eval declare -A %s=%s; %s .new %s\n' "$self" "${value:1:-1}" "$class" "$self" ;;
      *       ) printf 'eval declare -- %s=%s; %s .new %s\n' "$self" "$value"        "$class" "$self" ;;
    esac
    __=$value
    __classh[__]=String
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
    __inspect instance_methods
    __classh[__]=Array
  end

  def new <<'  end'
    local class=$1
    local self=$2; shift 2
    local value=${1-}
    local format
    local stdout
    local statement

    printf -v statement 'function %s { __dispatch "$@" ;}' "$self"
    eval "$statement"
    [[ $class == 'Class' ]] && __superh[$self]=Object
    __classh[$self]=$class
    __=''
    [[ -z $value ]] && return
    declare -f "$value" >/dev/null 2>&1 && {
      "$@"
      value=$__
    }
    case $value in
      '('* ) format='%s=%s';;
         * ) format='%s=%q';;
    esac
    printf -v statement "$format" "$self" "$value"
    eval "$statement"
    __=$value
    __classh[__]=String
  end

  def superclass <<'  end'
    local class=$1

    __=\"${__superh[$class]-}\"
    __classh[__]=String
  end
}

class Array : Object; {
  def concat <<'  end'
    local -n __vals=$1; shift
    local __results=()
    local __statement

    "$@"
    eval __results="$__"
    __vals+=( "${__results[@]}" )
    __inspect __vals
    __=${__:1:-1}
    __inspect "$__"
    __classh[__]=Array
  end

  def inspect <<'  end'
    __=$(declare -p "$1" 2>/dev/null) || return
    __=${__#*=}
    __=${__:1:-1}
    __classh[__]=Array
  end

  def join <<'  end'
    local -n __vals=$1
    local IFS=${2- }

    __=${__vals[*]}
    __classh[__]=String
  end

  def to_s <<'  end'
    __=$(declare -p "$1" 2>/dev/null) || return
    __=${__#*=}
    __=${__:1:-1}
    __classh[__]=String
  end
}

class Hash : Object; {
  def = <<'  end'
    local -n __self=$1; shift
    local statement

    { declare -f "$1" >/dev/null 2>&1 && [[ " ${!__classh[*]} " == *" $1 "* ]] ;} && {
      "$@"
      eval __self="$__"
      return
    }
    eval __self="$1"
    __=$1
    __classh[__]=String
  end

  def inspect <<'  end'
    __=$(declare -p "$1" 2>/dev/null) || return
    __=${__#*=}
    __=${__:1:-1}
    __classh[__]=Hash
  end

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

    __inspect __retvals
    __classh[__]=Array
  end

  def to_s <<'  end'
    __=$(declare -p "$1" 2>/dev/null) || return
    __=${__#*=}
    __=${__:1:-1}
    __classh[__]=String
  end
}

class String : Object; {
  def = <<'  end'
    local -n __self=$1; shift

    unset -v __
    { declare -f "$1" >/dev/null 2>&1 && [[ " ${!__classh[*]} " == *" $1 "* ]] ;} && {
      "$@"
      eval __self="$__"
      __classh[__]=String
      return
    }
    __self=$1
    __=$1
    __classh[__]=String
  end

  def inspect <<'  end'
    __=$(declare -p "$1" 2>/dev/null) || return
    __=${__#*=}
    __classh[__]=String
  end

  def to_s <<'  end'
    __=$(declare -p "$1" 2>/dev/null) || return
    __=${__#*=}
    __=${__:1:-1}
    __classh[__]=String
  end

  def upcase <<'  end'
    __=${!1^^}
    __classh[__]=String
  end

  def upcase! <<'  end'
    local -n __self=$1

    __self=${__self^^}
    __=$__self
    __classh[__]=String
  end
}
