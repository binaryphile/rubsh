#!/usr/bin/env bash

library=../lib/array.sh
source "${BASH_SOURCE%/*}/$library" 2>/dev/null || source "$library"
unset -v library

describe "Array.=="
  it "tests equality of two arrays"
    (
    sample=( "a" "b" "c" )
    expected=( "a" "b" "c" )
    Array.== sample expected
    assert equal $? 0
    )
  end

  it "detects inequality of two equal-length arrays"
    (
    sample=( "a" "b" "c" )
    expected=( "a" "b" "d" )
    Array.== sample expected
    assert equal $? 1
    )
  end

  it "detects inequality of two unequal-length arrays"
    (
    sample=( "a" "b" "c" )
    expected=( "a" "b" "c" "d" )
    Array.== sample expected
    assert equal $? 1
    )
  end
end

describe "Array.eql?"
  it "tests equality of two arrays"
    (
    sample=( "a" "b" "c" )
    expected=( "a" "b" "c" )
    Array.eql? sample expected
    assert equal $? 0
    )
  end

  it "detects inequality of two equal-length arrays"
    (
    sample=( "a" "b" "c" )
    expected=( "a" "b" "d" )
    Array.eql? sample expected
    assert equal $? 1
    )
  end

  it "detects inequality of two unequal-length arrays"
    (
    sample=( "a" "b" "c" )
    expected=( "a" "b" "c" "d" )
    Array.eql? sample expected
    assert equal $? 1
    )
  end
end

describe "Array.include?"
  it "tests for element membership"
    (
    # shellcheck disable=SC2034
    sample=( a b c )
    Array.include? sample "a"
    assert equal "$?" 0
    )
  end
end

describe "Array.index"
  it "finds the index of the first element on exact match"
    (
    # shellcheck disable=SC2034
    sample=( a b c )
    assert equal "$(Array.index sample "a")" 0
    )
  end

  it "finds the index of the second element on exact match"
    (
    # shellcheck disable=SC2034
    sample=( a b c )
    assert equal "$(Array.index sample "b")" 1
    )
  end
end

describe "Array.join"
  it "joins array elements"
    (
    # shellcheck disable=SC2034
    sample=( "a" "b" "c" )
    assert equal "$(Array.join sample "|")" "a|b|c"
    )
  end

  it "allows a variable delimiter"
    (
    # shellcheck disable=SC2034
    sample=( "a" "b" "c" )
    # shellcheck disable=SC2034
    delimiter="|"
    assert equal "$(Array.join sample delimiter)" "a|b|c"
    )
  end

  it "allows a multicharacter delimiter"
    (
    # shellcheck disable=SC2034
    sample=( "a" "b" "c" )
    assert equal "$(Array.join sample " | ")" "a | b | c"
    )
  end
end

describe "Array.new"
  it "adds an include? method"
    (
    # shellcheck disable=SC2034
    sample=( "" )
    Array.new sample
    sample.include? "a"
    assert equal $? 1
    )
  end

  it "allows a set of values initializer"
    (
    # shellcheck disable=SC2034
    declare sample
    Array.new sample "a" "b" "c"
    expected=( "a" "b" "c" )
    sample.eql? expected
    assert equal $? 0
    )
  end

  it "allows a string initializer"
    (
    # shellcheck disable=SC2034
    declare sample
    Array.new sample '( "a" "b" "c" )'
    expected=( "a" "b" "c" )
    sample.eql? expected
    assert equal $? 0
    )
  end

  it "adds an include? method which detects included items"
    (
    # shellcheck disable=SC2034
    sample=( "a" "b" )
    Array.new sample
    sample.include? "b"
    assert equal $? 0
    )
  end

  it "adds an index method"
    (
    # shellcheck disable=SC2034
    sample=( "a" "b" )
    Array.new sample
    assert equal "$(sample.index "b")" "1"
    )
  end

  it "adds the rest of the Array methods"
    (
    # shellcheck disable=SC2034
    sample=( "a" "b" )
    Array.new sample
    # shellcheck disable=SC2034
    result="$(sample.join "a")"
    result=( $(sample.remove "a") )
    result=( $(sample.slice 1 1 ) )
    )
  end
end

describe "Array.remove"
  it "removes the last element of an array on exact match"
    (
    # shellcheck disable=SC2034
    sample=( "a" "b" "c" )
    result=( $(Array.remove sample "c") )
    expected=( "a" "b" )
    assert equal "${result[*]}" "${expected[*]}"
    )
  end

  it "doesn't remove elements which aren't there"
    (
    # shellcheck disable=SC2034
    sample=( "a" "b" "c" )
    result=( $(Array.remove sample "d") )
    expected=( "a" "b" "c" )
    assert equal "${result[*]}" "${expected[*]}"
    )
  end
end

describe "Array.slice"
  it "returns the middle slice"
    (
    # shellcheck disable=SC2034
    sample=( "a" "b" "c" )
    result=( $(Array.slice sample 1 1) )
    expected=( "b" )
    assert equal "${result[*]}" "${expected[*]}"
    )
  end
end

describe "Array.to_s"
  it "exists"
    (
    # shellcheck disable=SC2034
    sample=( "a" "b" "c" )
    # shellcheck disable=SC2034
    result="$(Array.to_s sample)"
    assert equal $? 0
    )
  end
end
