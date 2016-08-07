#!/usr/bin/env bash

library=../lib/symbol.sh
source "${BASH_SOURCE%/*}/$library" 2>/dev/null || source "$library"
unset -v library

describe "Symbol.to_s"
  it "returns a string for a symbol literal"
    (
    assert equal "$(Symbol.to_s :sample)" "sample"
    )
  end
end
