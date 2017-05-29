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

export RUBSH_PATH=$(shpec_cwd)/../lib
source "$RUBSH_PATH"/keywords.rubsh

function? () { declare -f "$1" >/dev/null 2>&1 ;}
variable? () { declare -p "$1" >/dev/null 2>&1 ;}

describe class
  it "pushes __localh onto __stack"; (
    _shpec_failures=0
    class Sample
    assert equal '([self]="top_self" )' "${__stack[*]}"
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end

  it "sets self to the class id"; (
    _shpec_failures=0
    class Sample
    assert equal sample "$self"
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end

  it "creates a dispatch function for the class"; (
    _shpec_failures=0
    class Sample
    function? Sample
    assert equal 0 $?
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end

  it "creates a constant for the class"; (
    _shpec_failures=0
    class Sample
    assert equal sample "${__constanth[Sample]}"
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end

  it "records it in __classes"; (
    _shpec_failures=0
    class Sample
    [[ -n ${__classesh[sample]} ]]
    assert equal 0 $?
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end

  it "sets the class to the singleton class"; (
    _shpec_failures=0
    class Sample
    assert equal sample_singleton "${__classh[sample]}"
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end

  it "sets the class of the singleton class to itself"; (
    _shpec_failures=0
    class Sample
    assert equal sample_singleton "${__classh[sample_singleton]}"
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end

  it "defaults the super to 'object'"; (
    _shpec_failures=0
    class Sample
    assert equal object "${__superh[sample]}"
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end

  it "defaults the singleton's super to 'object_singleton'"; (
    _shpec_failures=0
    class Sample
    assert equal object_singleton "${__superh[sample_singleton]}"
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end

  it "sets the type to class"; (
    _shpec_failures=0
    class Sample
    assert equal class "${__typeh[sample]}"
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end

  it "sets the type of the singleton class to class"; (
    _shpec_failures=0
    class Sample
    assert equal class "${__typeh[sample_singleton]}"
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end

  it "sets the singleton attribute for the singleton class"; (
    _shpec_failures=0
    class Sample
    [[ -n ${__singletonh[sample_singleton]} ]]
    assert equal 0 $?
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end

  it "binds the class name"; (
    _shpec_failures=0
    class Sample
    assert equal Sample "${__ivarh[sample.name]}"
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end

  it "binds the singleton class"; (
    _shpec_failures=0
    class Sample
    assert equal sample "${__ivarh[sample_singleton.attached]}"
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end

  it "returns nil"; (
    _shpec_failures=0
    class Sample
    assert equal nil "$__"
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end

  it "removes the current self method functions"; (
    _shpec_failures=0
    __self_methodsh[example]=1
    example () { :;}
    class Sample
    stop_on_error off
    function? example
    assert unequal 0 $?
    stop_on_error
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end

  it "puts the old methods on the stack"; (
    _shpec_failures=0
    __self_methodsh[example]=1
    class Sample
    assert equal '([example]="1" )' "${__methods_stack[*]}"
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end

  it "adds the method functions names to __self_methods"; (
    _shpec_failures=0
    __method_bodyh[class#example]='echo hello'
    __methodsh[class]=' example'
    class Sample
    assert equal example "${!__self_methodsh[*]}"
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end

  it "implements the method functions"; (
    _shpec_failures=0
    __method_bodyh[class#example]='echo hello'
    __methodsh[class]=' example'
    class Sample
    assert equal example "${!__self_methodsh[*]}"
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end

  it "shovels the singleton class of self"; (
    _shpec_failures=0
    stop_on_error off
    class Sample
    class « self
    assert equal sample_singleton "$self"
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end

  it "sets self to the singleton class without arguments"; (
    _shpec_failures=0
    stop_on_error off
    class Sample
      class <<'      self'
        result=$self
      self
    rubend
    assert equal 2 "$result"
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end
end

describe def
  it "records the method name in __methodsh"; (
    _shpec_failures=0
    class Sample
    def example example
    assert equal ' example' "${__methodsh[sample]}"
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end

  it "stores the body in __method_bodyh"; (
    _shpec_failures=0
    class Sample
    def example example
    assert equal example "${__method_bodyh[sample#example]}"
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end

  it "adds a self function for the method"; (
    _shpec_failures=0
    class Sample
    def sample example
    function? sample
    assert equal 0 $?
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end

  it "records the method name in __self_methodsh"; (
    _shpec_failures=0
    class Sample
    def example example
    assert equal ' example' "${__methodsh[sample]}"
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end
end

describe __dispatch
  it "calls the named method"; (
    _shpec_failures=0
    __localh[example]=__0
    __classh[__0]=sample
    __classesh[sample]=1
    __superh[sample]=''
    __typeh[sample]=class
    __method_bodyh[sample#sample]='echo hello'
    example () { local self=__0; __dispatch "$@" ;}
    assert equal hello "$(example .sample)"
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end
end

describe rubend
  it "removes a self function"; (
    _shpec_failures=0
    class Sample
      function? new
      assert equal 0 $?
    rubend
    stop_on_error off
    function? new
    assert unequal 0 $?
    stop_on_error
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end
end
