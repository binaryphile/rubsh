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
source "$RUBSH_PATH"/require.rubsh
$(require init      )
$(require bootstrap )

function? () { declare -f "$1" >/dev/null 2>&1 ;}
variable? () { declare -p "$1" >/dev/null 2>&1 ;}

describe class
  it "pushes __class onto __stack"; (
    _shpec_failures=0

    class Sample
    assert equal object "${__stack[*]}"
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end

  it "sets __class to the class id"; (
    _shpec_failures=0

    class Sample
    assert equal sample "$__class"
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

  it "creates a method hash"; (
    _shpec_failures=0

    class Sample
    variable? __sample_methodsh
    assert equal 0 $?
    return "$_shpec_failures" ); : $(( _shpec_failures += $? ))
  end

  it "creates a singleton method hash"; (
    _shpec_failures=0

    class Sample
    variable? __sample_singleton_methodsh
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
end
