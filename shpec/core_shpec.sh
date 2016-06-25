#!/usr/bin/env bash

library=../lib/core.sh
source "${BASH_SOURCE%/*}/$library" 2>/dev/null || source "$library"

sample_f() { echo "hello"; }

describe "_rubsh.Array.to_s"
  it "renders a string version of an array"
    # shellcheck disable=SC2034
    sample_a=( "a" "b" "c" )
    # shellcheck disable=SC2034
    expected_s='("a" "b" "c")'
    # shellcheck disable=SC2034
    result_s="$(_rubsh.Array.to_s sample_a)"
    assert equal "$expected_s" "$result_s"
  end
end

describe "_rubsh.core.alias"
  it "aliases String.blank? function to core"
    # shellcheck disable=SC2034
    aliases_a=( "blank?" )
    _rubsh.core.alias String aliases_a
    # shellcheck disable=SC2034
    blank_s=""
    String.blank? blank_s
    assert equal $? 0
  end
end

describe "_rubsh.keyword.require"
  it "sources a file in bash path"
    # shellcheck disable=2154
    export RUBSH_PATH="$_rubsh_lib"
    _rubsh.keyword.require string
    String.blank? RUBSH_PATH
    assert equal $? 1
  end

describe "_rubsh.sh.alias_function"
  it "aliases a function"
    _rubsh.sh.alias_function sample2_f sample_f
    assert equal "$(sample2_f)" "hello"
  end
end

describe "_rubsh.String.blank?"
# TODO: fail undefined test
  it "checks for empty string"
    # shellcheck disable=SC2034
    sample_s=""
    _rubsh.String.blank? sample_s
    assert equal $? 0
  end

  it "checks for string with only spaces"
    # shellcheck disable=SC2034
    sample_s=" "
    _rubsh.String.blank? sample_s
    assert equal $? 0
  end

  it "checks for string with only tabs"
    # shellcheck disable=SC2034
    sample_s=" 	"
    _rubsh.String.blank? sample_s
    assert equal $? 0
  end

  it "doesn't match strings with characters"
    # shellcheck disable=SC2034
    sample_s="ab "
    _rubsh.String.blank? sample_s
    assert equal $? 1
  end
end

describe "_rubsh.sh.class"
  it "reports if it is an array"
    # shellcheck disable=SC2034
    sample_a=( 1 2 3 )
    assert equal "$(_rubsh.sh.class sample_a)" "array"
  end

  it "reports if it is a string"
    # shellcheck disable=SC2034
    sample_s="value"
    assert equal "$(_rubsh.sh.class sample_s)" "string"
  end
end

describe "_rubsh.sh.deref"
  it "dereferences a scalar variable"
    # shellcheck disable=SC2034
    sample_s="text sample"
    # shellcheck disable=SC2034
    indirect_v="sample_s"
    _rubsh.sh.deref indirect_v
    assert equal "$indirect_v" "text sample"
  end

  it "dereferences an array variable"
    # shellcheck disable=SC2034
    sample_a=( "testing" "one" "two" )
    # shellcheck disable=SC2034
    indirect_v="sample_a"
    _rubsh.sh.deref indirect_v
    assert equal "$(_rubsh.sh.class indirect_v)" "array"
    assert equal "${indirect_v[*]}" "${sample_a[*]}"
  end
end

describe "_rubsh.String.eql?"
  it "checks equality"
    # shellcheck disable=SC2034
    sample_s="abc"
    _rubsh.String.eql? sample_s "$sample_s"
    assert equal $? 0
  end

  it "fails inequality"
    # shellcheck disable=SC2034
    sample_s="abc"
    _rubsh.String.eql? sample_s ""
    assert equal $? 1
  end
end

describe "_rubsh.sh.value"
  it "returns a scalar value"
    # shellcheck disable=SC2034
    sample_s="value text"
    assert equal "$(_rubsh.sh.value sample_s)" "$sample_s"
  end

  it "returns an array value"
    # shellcheck disable=SC2034
    sample_a=( "one" "two" "three" )
    assert equal "$(_rubsh.sh.value sample_a)" "$(printf "%s " "${sample_a[@]}")"
  end
end
