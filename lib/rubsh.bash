[[ -n ${_rubsh:-} ]] && return
readonly _rubsh=loaded

unset -v __ __methodh
declare -Ag __methodh
__=''

class () {
  __class=$1 # global
  local parent=${3:-}

  [[ -n $parent ]] && {
    eval "$__class.new () { Object.new $parent "'"$@"'"; Object.new $__class "'"$@"'" ;}"
    return
  }
  eval "$__class.new () { Object.new $__class "'"$@"'" ;}"
}

def () {
  local method=$1
  local body=$(</dev/stdin)
  local tmp=()

  eval "$__class.$method () { $body ;}"
  tmp=( ${__methodh[$__class]} "$method" )
  __methodh[$__class]=${tmp[*]}
}

class Class; {
  def inherit <<'  end'
    local class=$1
    local self=$2
    local method

    for method in ${__methodh[$class]}; do
      eval "$self.$method () { $class.$method $self "'"$@"'" ;}"
    done
  end
}

class Object; {
  def new <<'  end'
    local class=$1; shift
    local self

    for self in "$@"; do
      eval "$self () { $self.to_s ;}"
      Class.inherit Object "$self"
      Class.inherit "$class" "$self"
    done
  end

  def set <<'  end'
    local -n __self=$1; shift

    __=''
    "$@"
    eval __self="$__"
  end

  def to_s <<'  end'
    local self=$1

    __=$(declare -p "$self" 2>/dev/null) || return
    __=${__#declare -* $self=}
  end
}

class Array; {
  def append <<'  end'
    local -n __vals=$1; shift
    local __statement

    case $# in
      '0' ) return;;
      '1' )
        printf -v __statement '__vals+=( "${%s[@]}" )' "$1"
        eval "$__statement"
        ;;
      * ) "$@"; __vals+=( "${__[@]}" );;
    esac
  end

  def join <<'  end'
    local -n __vals=$1; shift
    local IFS=$1

    __=${__vals[*]}
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

    __=( "${__retvals[@]}" )
  end
}

class String

defs () { IFS=$'\n' read -rd '' "$1" ||: ;}

puts () { printf '%s\n' "$1" ;}

class File , Path; {
  def each <<'  end'
    local __filename=${!1}
    local __lineparm=$3
    local __lambda=${4:-$(</dev/stdin)}
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

class Path; {
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
    __=$__pathname${__filename:+/}${__filename:-}
  end
}

[[ -n $shpec_test ]] && return
unset -v __class
unset -f class def
