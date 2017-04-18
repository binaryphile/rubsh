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

source "$(shpec_cwd)"/../lib/rubsh

is_function () { declare -f "$1" >/dev/null 2>&1 ;}

describe require
  it "loads a rubsh file from a specified path without an extension"; (
    _shpec_failures=0
    unset -v sample
    dir=$($mktempd) || return
    echo 'sample=example' >"$dir"/sample.rubsh
    $(require "$dir"/sample)
    assert equal example "$sample"
    shpec_cleanup "$dir"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "loads a rubsh file from a specified path with an extension"; (
    _shpec_failures=0
    unset -v sample
    dir=$($mktempd) || return
    echo 'sample=example' >"$dir"/sample.rubsh
    $(require "$dir"/sample.rubsh)
    assert equal example "$sample"
    shpec_cleanup "$dir"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "loads a bash file from a specified path without an extension"; (
    _shpec_failures=0
    unset -v sample
    dir=$($mktempd) || return
    echo 'sample=example' >"$dir"/sample.bash
    $(require "$dir"/sample)
    assert equal example "$sample"
    shpec_cleanup "$dir"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "loads a bash file from a specified path with an extension"; (
    _shpec_failures=0
    unset -v sample
    dir=$($mktempd) || return
    echo 'sample=example' >"$dir"/sample.bash
    $(require "$dir"/sample.bash)
    assert equal example "$sample"
    shpec_cleanup "$dir"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "loads a sh file from a specified path without an extension"; (
    _shpec_failures=0
    unset -v sample
    dir=$($mktempd) || return
    echo 'sample=example' >"$dir"/sample.sh
    $(require "$dir"/sample)
    assert equal example "$sample"
    shpec_cleanup "$dir"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "loads a sh file from a specified path with an extension"; (
    _shpec_failures=0
    unset -v sample
    dir=$($mktempd) || return
    echo 'sample=example' >"$dir"/sample.sh
    $(require "$dir"/sample.sh)
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
    $(require sample.rubsh)
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
    $(require sample.rubsh)
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
    $(require sample)
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
    $(require sample.bash)
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
    $(require sample)
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
    $(require sample.sh)
    assert equal example "$sample"
    shpec_cleanup "$dir"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "loads a rubsh file from the local directory without an extension"; (
    _shpec_failures=0
    unset -v sample
    echo 'sample=example' >sample.rubsh
    $(require sample)
    assert equal example "$sample"
    $rm sample.rubsh
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "loads a rubsh file from the local directory with an extension"; (
    _shpec_failures=0
    unset -v sample
    echo 'sample=example' >sample.rubsh
    $(require sample.rubsh)
    assert equal example "$sample"
    $rm sample.rubsh
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "loads a bash file from the local directory without an extension"; (
    _shpec_failures=0
    unset -v sample
    echo 'sample=example' >sample.bash
    $(require sample)
    assert equal example "$sample"
    $rm sample.bash
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "loads a bash file from the local directory with an extension"; (
    _shpec_failures=0
    unset -v sample
    echo 'sample=example' >sample.bash
    $(require sample.bash)
    assert equal example "$sample"
    $rm sample.bash
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "loads a sh file from the local directory without an extension"; (
    _shpec_failures=0
    unset -v sample
    echo 'sample=example' >sample.sh
    $(require sample)
    assert equal example "$sample"
    $rm sample.sh
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "loads a sh file from the local directory with an extension"; (
    _shpec_failures=0
    unset -v sample
    echo 'sample=example' >sample.sh
    $(require sample.sh)
    assert equal example "$sample"
    $rm sample.sh
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "doesn't reload a loaded file"; (
    _shpec_failures=0
    echo 'sample=example' >sample.rubsh
    $(require sample)
    unset -v sample
    require sample
    assert unequal example "${sample-}"
    $rm sample.rubsh
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end
end
