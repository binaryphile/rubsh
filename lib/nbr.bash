# Note the use of triple underscores for the class functions

declare -Ag ___methodh

class () { ___class=$1 ;}

def () {
  local ___method=$1
  local ___body=$(</dev/stdin)
  local ___statement

  printf -v ___statement 'function %s.%s { %s ;}' "$___class" "$___method" "$___body"
  eval "$___statement"
  ___methodh[$___class]+="$___method "
}

class Class; {
  def new <<'  end'
    local ___class=$1; shift
    local ___methods=( ${___methodh[$___class]} )
    local ___name

    for ___name in "$@"; do
      Class.inherit "$___class" ___name ___methods
    done
  end

  # four underscores
  def inherit <<'  end'
    local ____class=$1
    local ____name=${!2}
    local -n ____methods=$3
    local ____method
    local ____separator
    local ____statement

    for ____method in "${____methods[@]}"; do
      case $____method in
        'new'         ) continue          ;;
        [[:alpha:]]*  ) ____separator=.   ;;
        *             ) ____separator=''  ;;
      esac
      printf -v ____statement 'function %s%s%s { %s.%s %s "$@" ;}' "$____name" "$____separator" "$____method" "$____class" "$____method" "$____name"
      eval "$____statement"
    done
  end
}

class Array; {
  def new <<'  end'
    Class.new Array "$@"
  end

  def += <<'  end'
    local -n __vals=$1; shift
    local __statement

    case $# in
      '0' ) return;;
      '1' )
        printf -v __statement '__vals+=( "${%s[@]}" )' "$1"
        eval "$__statement"
        ;;
      *   ) "$@"; __vals+=( "${__[@]}" );;
    esac
  end

  def = <<'  end'
    local -n __vals=$1; shift
    local __statement

    case $# in
      '0' ) return;;
      '1' )
        printf -v __statement '__vals=( "${%s[@]}" )' "$1"
        eval "$__statement"
        ;;
      *   ) "$@"; __vals=( "${__[@]}" );;
    esac
  end

  def join <<'  end'
    local -n __vals=$1; shift
    local IFS=$1

    __=${__vals[*]}
  end
}

class Hash; {
  def new <<'  end'
    Class.new Hash "$@"
  end

  def = <<'  end'
    local -n __valh=$1; shift

    case $# in
      '0' ) return          ;;
      '1' ) Hash.to_s "$1"  ;;
      *   ) "$@"            ;;
    esac
    eval __valh="$__"
  end

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

    printf -v __statement '__retvals+=( "$(echo "%s")" )' "$__lambda"

    for __key in "${!__valh[@]}"; do
      printf -v "$__keyparm" '%s' "$__key"
      printf -v "$__valparm" '%s' "${__valh[$__key]}"
      eval "$__statement"
    done

    __=( "${__retvals[@]}" )
  end

  def to_s <<'  end'
    local __name=$1
    local __result

    result=$(declare -p "$__name")
    result=${result#declare -A $__name=}
    __=${result:1:${#result}-2}
  end
}

class String; {
  def new <<'  end'
    Class.new String "$@"
  end

  def = <<'  end'
    local val=$1; shift

    case $# in
      '0' ) return                            ;;
      '1' ) printf -v "$val" '%s' "${!1}"     ;;
      *   ) "$@"; printf -v "$val" '%s' "$__" ;;
    esac
  end
}

defs () { IFS=$'\n' read -rd '' "$1" ||: ;}

puts () { printf '%s\n' "$1" ;}

class File; {
  def new <<'  end'
    Path.new "$@"
    Class.new File "$@"
  end

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
    echo "$__string" >"$__filename"
  end
}

class Path; {
  def new <<'  end'
    String.new "$@"
    Class.new Path "$@"
  end

  def expand_path <<'  end'
    local pathname=${!1}
    local filename

    unset -v CDPATH
    [[ -e $pathname ]] && {
      filename=$(basename "$pathname")
      pathname=$(dirname "$pathname")
    }
    pathname=$(cd "$pathname" && pwd) || return
    __=$pathname${filename:+/}${filename:-}
  end
}
