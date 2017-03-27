[[ -n ${_rubsh:-} && -z ${reload:-} ]] && return
[[ -n ${reload:-}                   ]] && { unset -v reload && echo reloaded || return ;}
[[ -z ${_rubsh:-}                   ]] && readonly _rubsh=loaded

unset   -v  __classh __method_bodyh __methodsh __
declare -Ag __classh __method_bodyh __methodsh
__=''

defs () { IFS=$'\n' read -rd '' "$1" ||: ;}

defs __method_bodyh[Object.ancestors] <<'end'
  __='([0]="Object")'
end

defs __method_bodyh[Object.class] <<'end'
  __=${__classh[Object]}
end

defs __method_bodyh[Object.methods] <<'end'
  __='([0]="ancestors" [1]="methods")'
end

defs __method_bodyh[Class.ancestors] <<'end'
  __='([0]="Class" [1]="Object")'
end

defs __method_bodyh[Class.methods] <<'end'
  __='([0]="ancestors" [1]="methods")'
end

__dispatch () {
  local method=$1
  local self=${FUNCNAME[1]}
  local statement

  printf -v statement 'function __ { %s ;}; __ "$self" "$@"' "${__method_bodyh[$self.$method]}"
  eval "$statement"
}

for class in Object Class; do
  printf -v statement 'function %s { __dispatch "$@" ;}' "$class"
  eval "$statement"
  __classh[$class]=Class
done
unset -v class statement
