source import.bash

shpec_helper_imports=(
  initialize_shpec_helper
  shpec_cwd
  stop_on_error
)
eval "$(importa shpec-helper shpec_helper_imports)"
initialize_shpec_helper
stop_on_error=true
stop_on_error

source "$(shpec_cwd)"/../lib/utils.rubsh

is_function () { declare -f "$1" >/dev/null 2>&1 ;}

describe __inspect
  it "returns a string's eval'able value"; (
    _shpec_failures=0
    sample='an example'
    __inspect sample
    eval result="$__"
    assert equal 'an example' "$result"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "returns an array's eval'able value"; (
    _shpec_failures=0
    samples=( zero one )
    __inspect samples
    eval results="$__"
    assert equal 'zero one' "${results[*]}"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "returns a hash's eval'able value"; (
    _shpec_failures=0
    declare -A sampleh=( [zero]=0 [one]=1 )
    __inspect sampleh
    declare -A resulth
    eval resulth="$__"
    assert equal '0 1' "${resulth[zero]} ${resulth[one]}"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end
end

describe __next_id
  it "returns a number"; (
    _shpec_failures=0
    __next_id
    expression='^[[:digit:]]+$'
    [[ $__ =~ $expression ]]
    assert equal 0 $?
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "returns different numbers on subsequent calls"; (
    _shpec_failures=0
    __next_id
    result=$__
    __next_id
    assert unequal "$result" "$__"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end
end
