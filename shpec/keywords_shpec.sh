#!/usr/bin/env bash

# https://stackoverflow.com/questions/192292/bash-how-best-to-include-other-scripts/12694189#12694189
[[ -d ${BASH_SOURCE%/*} ]] && _shpec_dir="${BASH_SOURCE%/*}" || _shpec_dir="$PWD"

source "$_shpec_dir"/../lib/keywords.sh
export RUBSH_PATH="$_shpec_dir"/../lib
require "string"
require "array"

describe "new"
  it "assigns a string object"
    new sample_s = String.new "text"
    # shellcheck disable=SC2154
    assert equal "$sample_s" "text"
  end

  it "assigns an array object"
    new sample_a = Array.new "a" "b"
    assert equal "$(sample_a.to_s)" '( "a" "b" )'
  end
end
