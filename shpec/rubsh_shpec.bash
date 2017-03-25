source import.bash

shpec_helper_imports=(
  initialize_shpec_helper
  shpec_source
  stop_on_error
)
eval "$(importa shpec-helper shpec_helper_imports)"
initialize_shpec_helper
stop_on_error=true
stop_on_error

shpec_test=true
shpec_source lib/rubsh.bash

describe __
  it "is blank"
    assert equal 'declare -- __=""' "$(declare -p __)"
  end
end

describe ___class
  it "is not set"
    stop_on_error off
    declare -p ___class >/dev/null 2>&1
    assert unequal 0 $?
    stop_on_error
  end
end

describe ___methodh
  it "catalogues the methods of classes"
    read -r expected <<'    EOS' ||:
      declare -A __methodh='([Object]="new set to_s" [Array]="append join" [Class]="new inherit" [Hash]="map" [File]="each write" [Path]="expand_path" )'
    EOS
    assert equal "$expected" "$(declare -p __methodh)"
  end
end

describe class
  it "sets __class globally"; (
    class Sample
    assert equal Sample "$__class"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "assigns Object as the default parent"; (
    class Sample
    assert equal Object "${__parenth[Sample]}"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end
end

describe def
  it "creates a method"; (
    __class=Sample
    read -rd '' expected <<'    EOS' ||:
Sample.example () 
{ 
    :
}
    EOS
    def example <<<:
    assert equal "$expected" "$(declare -f Sample.example)"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end
end

describe Class.new
  it "creates Object methods"; (
    Class.new Sample example
    IFS=$'\n' read -rd '' -a results <<<"$(declare -F | grep example\.)" ||:
    results=( "${results[@]#declare -f example.}" )
    assert equal "${__methodh[Object]}" "${results[*]}"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "creates methods of the specified class in addition"; (
    Class.new Class example
    IFS=$'\n' read -rd '' -a results <<<"$(declare -F | grep example\.)" ||:
    results=( "${results[@]#declare -f example.}" )
    assert equal "inherit new set to_s" "${results[*]}"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "creates an instance-named function"; (
    Class.new Sample example
    declare -f example >/dev/null
    assert equal 0 $?
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "does so for multiple instances"; (
    Class.new Sample example1 example2
    declare -f example1 >/dev/null
    results=( $? )
    declare -f example2 >/dev/null
    results+=( $? )
    assert equal '0 0' "${results[*]}"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end
end

describe Class.inherit
  it "creates instance methods from a class"; (
    Class.inherit Class sample
    assert equal $'declare -f sample.inherit\ndeclare -f sample.new' "$(declare -F | grep sample\.)"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end
end
#
# describe Object.new
#   it "creates methods from a specified class"; (
#     Object.new sample
#     assert equal $'declare -f sample\ndeclare -f sample.new\ndeclare -f sample.set\ndeclare -f sample.to_s' "$(declare -F | grep sample)"
#     return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
#   end
# end
