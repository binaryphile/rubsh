#!/usr/bin/env bash

library=../lib/keyword.sh
source "${BASH_SOURCE%/*}/$library" 2>/dev/null || source "$library"

describe "new"
  it "assigns a string object"
    # shellcheck disable=SC2154
    source "$_rubsh_lib"/string.sh
    new sample_s = String.new "text"
    # shellcheck disable=SC2154
    assert equal "$sample_s" "text"
  end

  it "assigns an array object"
    source "$_rubsh_lib"/array.sh
    new sample_a = Array.new "a" "b"
    assert equal "$(sample_a.to_s)" '("a" "b")'
  end
end
