source import.bash

shpec_helper_imports=(
  initialize_shpec_helper
  shpec_cwd
  shpec_cleanup
  stop_on_error
)
eval "$(importa shpec-helper shpec_helper_imports)"
initialize_shpec_helper
stop_on_error=true
stop_on_error

source "$(shpec_cwd)"/../lib/rubsh.bash

is_function () { declare -f "$1" >/dev/null 2>&1 ;}

describe __dispatch
  it "allows a literal String object"; (
    _shpec_failures=0
    String "an example" .class
    assert equal '"String"' "$__"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "calls #inspect on a bare object literal"; (
    _shpec_failures=0
    String "an example"
    assert equal '"an example"' "$__"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "allows a literal Array object"; (
    _shpec_failures=0
    Array '( zero one )' .class
    assert equal '"Array"' "$__"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "allows a literal Hash object"; (
    _shpec_failures=0
    Hash '( [zero]=0 [one]=1 )' .class
    assert equal '"Hash"' "$__"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "implicitly calls #inspect"; (
    _shpec_failures=0
    String .new sample "an example"
    sample
    assert equal '"an example"' "$__"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "allows a bare = on .= calls"; (
    _shpec_failures=0
    String .new sample "an example"
    sample = "a result"
    assert equal "a result" "$sample"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "allows braces on method calls"; (
    _shpec_failures=0
    unset -v sample
    unset -f sample
    String .new { sample "an example" }
    is_function sample
    assert equal 0 $?
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "does basic method chaining with braces"; (
    _shpec_failures=0
    Array .new samples '( one two )'
    samples .join { - } .class
    assert equal '"String"' "$__"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "sets self"; (
    _shpec_failures=0
    class Sample; {
      def self <<'      end'
        __=\"$self\"
      end
    }
    Sample .new sample
    sample .self
    assert equal '"sample"' "$__"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end
end
