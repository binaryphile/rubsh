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

describe inspect
  it "returns an eval'able right-hand side string representation of the contents of the object"; (
    _shpec_failures=0
    String .new sample "an example"
    sample .inspect
    assert equal '"an example"' "$__"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end
end

describe =
  it "sets the associated variable with a literal string"; (
    _shpec_failures=0
    String .new sample "an example"
    sample .= "a result"
    assert equal "a result" "$sample"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "sets the associated variable with the output left in __ by the last command"; (
    _shpec_failures=0
    String .new sample "an example"
    String .new result "a result"
    sample .= result
    assert equal "a result" "$sample"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end
end

describe to_s
  it "returns a printable string from the associated variable"; (
    _shpec_failures=0
    String .new sample "an example"
    sample .to_s
    assert equal "an example" "$__"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end
end

describe upcase
  it "returns an upper-cased version of the string"; (
    _shpec_failures=0
    String .new sample "an example"
    sample .upcase
    assert equal "AN EXAMPLE" "$__"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end
end

describe upcase!
  it "changes the string to upper-case"; (
    _shpec_failures=0
    String .new sample "an example"
    sample .upcase!
    assert equal "AN EXAMPLE" "$sample"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end
end
