#!/usr/bin/env bash

library=../lib/io.sh
source "${BASH_SOURCE%/*}/$library" 2>/dev/null || source "$library"
unset -v library

describe "IO.puts"
  it "echos to stdout"
    (
    sample="test"
    assert equal "$(IO.puts "$sample")" "test"
    )
  end
end

describe "IO.printf"
  it "printfs to stdout"
    (
    sample="test"
    assert equal "$(IO.printf "%s\n" "$sample")" "test"
    )
  end
end

describe "stdout.printf"
  it "printfs to stdout"
    (
    sample="test"
    assert equal "$(stdout.printf "%s\n" "$sample")" "test"
    )
  end
end

describe "stdout.puts"
  it "echos to stdout"
    (
    sample="test"
    assert equal "$(stdout.puts "$sample")" "test"
    )
  end
end
