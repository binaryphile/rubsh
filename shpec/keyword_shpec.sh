#!/usr/bin/env bash

library=../lib/keyword.sh
source "${BASH_SOURCE%/*}/$library" 2>/dev/null || source "$library"
unset -v library

describe "__dir__"
  it "evals to the absolute directory of this file"
    (
    # shellcheck disable=SC2154
    result=$(__dir__)
    assert equal "$result" "$HOME"/.basher/cellar/packages/binaryphile/rubsh/shpec
    )
  end
end

describe "__FILE__"
  it "evals to the relative path of this file"
    (
    result=$(__FILE__)
    assert equal "$result" "${BASH_SOURCE}"
    )
  end
end

describe "new"
  it "assigns a string object"
    (
    # shellcheck disable=SC2154
    source "$_rubsh_lib"/string.sh
    sample=""
    new sample = String.new "text"
    # shellcheck disable=SC2154
    assert equal "$sample" "text"
    )
  end

  it "assigns an array object with multiple initializer arguments"
    (
    source "$_rubsh_lib"/array.sh
    sample=""
    new sample = Array.new "a" "b"
    assert equal "$(sample.inspect)" '("a" "b")'
    )
  end

  it "assigns an array object with one initializer argument"
    (
    source "$_rubsh_lib"/array.sh
    sample=""
    new sample = Array.new '( "a" "b" )'
    assert equal "$(sample.inspect)" '("a" "b")'
    )
  end
end
