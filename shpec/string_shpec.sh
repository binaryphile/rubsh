#!/usr/bin/env bash

source "${BASH_SOURCE%/*}"/../lib/string.sh 2>/dev/null || source ../lib/string.sh

describe "String.split"
  it "splits on the specified delimiter"
    # shellcheck disable=SC2034
    sample_s="a/b/c"
    assert equal "$(String.split sample_s "/")" "a b c"
  end
end

describe "String.eql?"
  it "exists"
    # shellcheck disable=SC2034
    sample_s="abc"
    String.eql? sample_s "abc"
    assert equal $? 0
  end
end

describe "String.blank?"
  it "exists"
    # shellcheck disable=SC2034
    blank_s=""
    String.blank? blank_s
    assert equal $? 0
  end
end

describe "String.new"
  it "allows an initializer"
    # shellcheck disable=SC2034
    declare sample_s
    String.new sample_s "text"
    # shellcheck disable=SC2034
    sample_s.eql? "text"
    assert equal $? 0
  end

  it "adds a blank? method"
    # shellcheck disable=SC2034
    sample_s=""
    String.new sample_s
    sample_s.blank?
    assert equal $? 0
  end

  it "adds a blank? method which detects non-blanks"
    # shellcheck disable=SC2034
    sample_s="a"
    String.new sample_s
    sample_s.blank?
    assert equal $? 1
  end

  it "adds a eql? method"
    # shellcheck disable=SC2034
    sample_s="a"
    String.new sample_s
    sample_s.eql? "a"
    assert equal $? 0
  end

  it "adds a eql? method which detects inequality"
    # shellcheck disable=SC2034
    sample_s="a"
    String.new sample_s
    sample_s.eql? "b"
    assert equal $? 1
  end

  it "adds the rest of the String methods"
    # shellcheck disable=SC2034
    sample_s="a"
    String.new sample_s
    # shellcheck disable=SC2034
    result="$(sample_s.split)"
    sample_s.exit_if_blank?
    assert equal $? 0
  end
end
