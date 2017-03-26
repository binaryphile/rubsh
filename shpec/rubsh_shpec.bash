source import.bash

shpec_helper_imports=(
  initialize_shpec_helper
  stop_on_error
)
eval "$(importa shpec-helper shpec_helper_imports)"
initialize_shpec_helper
stop_on_error=true
stop_on_error

shpec_test=true
eval "$shpec_source/lib/rubsh.bash"

describe __dispatch
  it "determines self from the calling function"; (
    __parenth[samplef]=example
    __bodyh[example.example]='echo $1'

    samplef () { __dispatch "$@" ;}
    assert equal samplef "$(samplef example)"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "creates a method from the body hash"; (
    __parenth[samplef]=example
    __bodyh[example.example]='echo $1'

    samplef () { __dispatch "$@" ;}
    assert equal samplef "$(samplef example)"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end
end

# describe class
#   it "sets __class globally"; (
#     class Sample
#     assert equal Sample "$__class"
#     return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
#   end
#
#   it "calls Class.new"; (
#     stub_command Class.new 'echo "$@"'
#
#     assert equal Sample "$(Class.new Sample)"
#     return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
#   end
#
#   it "assigns Object as the default parent"; (
#     stub_command Class.new
#
#     class Sample
#     assert equal Object "${__parenth[Sample]}"
#     return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
#   end
#
#   it "assigns the given parent"; (
#     stub_command Class.new
#
#     class Sample , Other
#     assert equal Other "${__parenth[Sample]}"
#     return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
#   end
# end
#
# describe def
#   it "creates a method"; (
#     __class=Sample
#     read -rd '' expected <<'    EOS' ||:
# Sample.example () 
# { 
#     :
# }
#     EOS
#     def example <<<:
#     assert equal "$expected" "$(declare -f Sample.example)"
#     return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
#   end
# end

describe Object

# describe Object.new
#   it "creates methods from a specified class"; (
#     Object.new sample
#     assert equal $'declare -f sample\ndeclare -f sample.new\ndeclare -f sample.set\ndeclare -f sample.to_s' "$(declare -F | grep sample)"
#     return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
#   end
# end
  it "is a function"
    declare -f Object >/dev/null
    assert equal 0 $?
  end

  it "calls __dispatch"; (
    stub_command __dispatch 'echo called'

    assert equal called "$(Object)"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  describe methods
    it "returns the methods defined on the object"
      Object methods
      assert equal '([0]="methods")' "$__"
    end
  end
end

describe Class
  it "is a function"
    declare -f Class >/dev/null
    assert equal 0 $?
  end

  it "is a child of Object"
    assert equal Object "${__parenth[Class]}"
  end

  describe new
    it "creates a new object"; (
      Class new Sample
      declare -f Sample >/dev/null
      assert equal 0 $?
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end

    it "creates multiples"; (
      Class new Sample Example
      declare -f Example >/dev/null
      assert equal 0 $?
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end

    it "sets the parent to Class"; (
      Class new Sample
      assert equal Class "${__parenth[Sample]}"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end

    it "creates Object methods"; (
      Class new Sample
      Sample methods
      assert equal '([0]="methods")' "$__"
      return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
    end
  end
end
