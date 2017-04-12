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

source "$(shpec_cwd)"/../lib/rubsh.bash

describe =
  it "sets the associated variable with a literal string"; (
    _shpec_failures=0
    declare -A sampleh
    Hash .new sampleh '( [zero]=0 )'
    sampleh .= '( [one]=1 )'
    assert equal 'declare -A sampleh='\''([one]="1" )'\' "$(declare -p sampleh)"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "sets the associated variable with the output left in __ by the last command"; (
    _shpec_failures=0
    declare -A sampleh resulth
    Hash .new sampleh '( [zero]=0 )'
    Hash .new resulth '( [one]=1 )'
    sampleh .= resulth
    assert equal 'declare -A sampleh='\''([one]="1" )'\' "$(declare -p sampleh)"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end
end

describe map
  it "returns an array of values mapped with a normal block"; (
    _shpec_failures=0
    declare -A sampleh
    Hash .new sampleh '( [zero]=0 [one]=1 )'
    sampleh .map [ {k,v} '$k: $v' ]
    assert equal '([0]="one: 1" [1]="zero: 0")' "$__"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "returns an array of values mapped with a heredoc block"; (
    _shpec_failures=0
    declare -A sampleh
    Hash .new sampleh '( [zero]=0 [one]=1 )'
    sampleh .map do {k,v} <<'    end'
      $k: $v
    end
    assert equal '([0]="one: 1" [1]="zero: 0")' "$__"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end
end

describe to_s
  it "returns a string interpretation of a hash"; (
    _shpec_failures=0
    declare -A sampleh
    Hash .new sampleh '( [zero]=0 [one]=1 )'
    sampleh .to_s
    assert equal '([one]="1" [zero]="0" )' "$__"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end
end
