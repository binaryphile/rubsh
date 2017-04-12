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

describe class
  it "sets __class"; (
    _shpec_failures=0
    class Sample
    assert equal Sample "$__class"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "fails if the inheritance operator is not :"; (
    _shpec_failures=0
    stop_on_error off
    class Sample , Class
    assert unequal 0 $?
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "fails if the superclass is given but the class already exists as a function"; (
    _shpec_failures=0
    Sample () { :;}
    stop_on_error off
    class Sample : Class
    assert unequal 0 $?
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "fails if the superclass is given but doesn't already exist as a function"; (
    _shpec_failures=0
    unset -f Test
    stop_on_error off
    class Sample : Test
    assert unequal 0 $?
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "tracks the superclass"; (
    _shpec_failures=0
    Test () { :;}
    class Sample : Test
    assert equal Test "${__superh[Sample]}"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "creates the class function"; (
    _shpec_failures=0
    class Sample
    is_function Sample
    assert equal 0 $?
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "sets the class to Class"; (
    _shpec_failures=0
    class Sample
    assert equal Class "${__classh[Sample]}"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "returns nothing"; (
    _shpec_failures=0
    unset -v __
    class Sample
    assert equal '""' "$__"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "sets self"; (
    _shpec_failures=0
    class Sample
    self
    assert equal '"Sample"' "$__"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end
end

describe def
  it "tracks the method's class"; (
    _shpec_failures=0
    class Sample
    def sample ''
    assert equal ' sample ' "${__methodsh[Sample]}"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "tracks the class of the method"; (
    _shpec_failures=0
    class Sample
    def sample ''
    assert equal ' Sample ' "${__method_classesh[sample]}"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "records the method body"; (
    _shpec_failures=0
    class Sample
    def sample 'example'
    assert equal example "${__method_bodyh[Sample.sample]}"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "records the method body given as a heredoc"; (
    _shpec_failures=0
    class Sample
    def sample <<'    end'
      example
    end
    assert equal '      example' "${__method_bodyh[Sample.sample]}"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "returns nothing"; (
    _shpec_failures=0
    unset -v __
    class Sample
    def sample ''
    assert equal '""' "$__"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end
end

describe puts
  it "prints the given argument"
    assert equal "an example" "$(puts "an example")"
  end

  it "prints additional arguments on successive lines"
    assert equal $'an example\nof two arguments' "$(puts "an example" "of two arguments")"
  end

  it "calls to_s on an object"; (
    _shpec_failures=0
    String .new sample "an example"
    assert equal "an example" "$(puts sample)"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "calls to_s on the output of a method"; (
    _shpec_failures=0
    Array .new samples '( zero one )'
    assert equal "zero-one" "$(puts samples .join -)"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end
end

describe self
  it "is a String"
    self .class
    assert equal '"String"' "$__"
  end

  it "is 'main' in the main context"
    self
    assert equal '"main"' "$__"
  end
end
