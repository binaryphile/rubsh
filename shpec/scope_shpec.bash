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

set -x
source "$(shpec_cwd)"/../lib/rubsh

describe __ruby_scopes
  it "is an array"; (
    _shpec_failures=0
    [[ $(declare -p __ruby_scopes) == 'declare -a'* ]]
    assert equal 0 $?
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end
end

describe get_scope
  it "returns a hash"; (
    _shpec_failures=0
    declare -p __ruby_values
    get_scope 0
    assert equal __h "$__"
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
end
