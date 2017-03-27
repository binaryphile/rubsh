[[ -n ${_rubsh:-} && -z ${reload:-} ]] && return
[[ -n ${reload:-}                   ]] && { unset -v reload && echo reloaded || return ;}
[[ -z ${_rubsh:-}                   ]] && readonly _rubsh=loaded

unset -v __classh __method_bodyh __methodsh
declare -Ag __classh __method_bodyh __methodsh

defs () { IFS=$'\n' read -rd '' "$1" ||: ;}

__classh[Class]=' Object '

__methodsh[ancestors]=' Class '
__methodsh[methods]=' Class '

defs __method_bodyh[Class.ancestors] <<'end'
  __='([0]="Object")'
end

defs __method_bodyh[Class.methods] <<'end'
  __='([0]="ancestors" [1]="methods")'
end

Object () { :;}

Class () {
  local method=$1
  local statement

  printf -v statement '__ () { %s ;}; __ Class "$@"' "${__method_bodyh[Class.$method]}"
  eval "$statement"
}
