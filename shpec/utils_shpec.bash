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
end

describe require
  it "loads a rubsh file from a specified path without an extension"; (
    _shpec_failures=0
    unset -v sample
    dir=$($mktempd) || return
    echo 'sample=example' >"$dir"/sample.rubsh
    require "$dir"/sample
    assert equal example "$sample"
    shpec_cleanup "$dir"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "loads a rubsh file from a specified path with an extension"; (
    _shpec_failures=0
    unset -v sample
    dir=$($mktempd) || return
    echo 'sample=example' >"$dir"/sample.rubsh
    require "$dir"/sample.rubsh
    assert equal example "$sample"
    shpec_cleanup "$dir"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "loads a bash file from a specified path without an extension"; (
    _shpec_failures=0
    unset -v sample
    dir=$($mktempd) || return
    echo 'sample=example' >"$dir"/sample.bash
    require "$dir"/sample
    assert equal example "$sample"
    shpec_cleanup "$dir"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "loads a bash file from a specified path with an extension"; (
    _shpec_failures=0
    unset -v sample
    dir=$($mktempd) || return
    echo 'sample=example' >"$dir"/sample.bash
    require "$dir"/sample.bash
    assert equal example "$sample"
    shpec_cleanup "$dir"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "loads a sh file from a specified path without an extension"; (
    _shpec_failures=0
    unset -v sample
    dir=$($mktempd) || return
    echo 'sample=example' >"$dir"/sample.sh
    require "$dir"/sample
    assert equal example "$sample"
    shpec_cleanup "$dir"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "loads a sh file from a specified path with an extension"; (
    _shpec_failures=0
    unset -v sample
    dir=$($mktempd) || return
    echo 'sample=example' >"$dir"/sample.sh
    require "$dir"/sample.sh
    assert equal example "$sample"
    shpec_cleanup "$dir"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "loads a rubsh file from RUBSH_PATH without an extension"; (
    _shpec_failures=0
    unset -v sample
    dir=$($mktempd) || return
    export RUBSH_PATH=$dir
    echo 'sample=example' >"$dir"/sample.rubsh
    require sample.rubsh
    assert equal example "$sample"
    shpec_cleanup "$dir"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "loads a rubsh file from RUBSH_PATH with an extension"; (
    _shpec_failures=0
    unset -v sample
    dir=$($mktempd) || return
    export RUBSH_PATH=$dir
    echo 'sample=example' >"$dir"/sample.rubsh
    require sample.rubsh
    assert equal example "$sample"
    shpec_cleanup "$dir"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "loads a bash file from RUBSH_PATH without an extension"; (
    _shpec_failures=0
    unset -v sample
    dir=$($mktempd) || return
    export RUBSH_PATH=$dir
    echo 'sample=example' >"$dir"/sample.bash
    require sample
    assert equal example "$sample"
    shpec_cleanup "$dir"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "loads a bash file from RUBSH_PATH with an extension"; (
    _shpec_failures=0
    unset -v sample
    dir=$($mktempd) || return
    export RUBSH_PATH=$dir
    echo 'sample=example' >"$dir"/sample.bash
    require sample.bash
    assert equal example "$sample"
    shpec_cleanup "$dir"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "loads a sh file from RUBSH_PATH without an extension"; (
    _shpec_failures=0
    unset -v sample
    dir=$($mktempd) || return
    export RUBSH_PATH=$dir
    echo 'sample=example' >"$dir"/sample.sh
    require sample
    assert equal example "$sample"
    shpec_cleanup "$dir"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "loads a sh file from RUBSH_PATH with an extension"; (
    _shpec_failures=0
    unset -v sample
    dir=$($mktempd) || return
    export RUBSH_PATH=$dir
    echo 'sample=example' >"$dir"/sample.sh
    require sample.sh
    assert equal example "$sample"
    shpec_cleanup "$dir"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "loads a rubsh file from the local directory without an extension"; (
    _shpec_failures=0
    unset -v sample
    echo 'sample=example' >sample.rubsh
    require sample
    assert equal example "$sample"
    $rm sample.rubsh
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "loads a rubsh file from the local directory with an extension"; (
    _shpec_failures=0
    unset -v sample
    echo 'sample=example' >sample.rubsh
    require sample.rubsh
    assert equal example "$sample"
    $rm sample.rubsh
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "loads a bash file from the local directory without an extension"; (
    _shpec_failures=0
    unset -v sample
    echo 'sample=example' >sample.bash
    require sample
    assert equal example "$sample"
    $rm sample.bash
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "loads a bash file from the local directory with an extension"; (
    _shpec_failures=0
    unset -v sample
    echo 'sample=example' >sample.bash
    require sample.bash
    assert equal example "$sample"
    $rm sample.bash
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "loads a sh file from the local directory without an extension"; (
    _shpec_failures=0
    unset -v sample
    echo 'sample=example' >sample.sh
    require sample
    assert equal example "$sample"
    $rm sample.sh
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "loads a sh file from the local directory with an extension"; (
    _shpec_failures=0
    unset -v sample
    echo 'sample=example' >sample.sh
    require sample.sh
    assert equal example "$sample"
    $rm sample.sh
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "doesn't reload a loaded file"; (
    _shpec_failures=0
    echo 'sample=example' >sample.rubsh
    require sample
    unset -v sample
    require sample
    assert unequal example "${sample-}"
    $rm sample.rubsh
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end
end
