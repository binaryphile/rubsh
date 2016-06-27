#!/usr/bin/env bash

library=../lib/string.sh
source "${BASH_SOURCE%/*}/$library" 2>/dev/null || source "$library"

describe "String.split"
  it "splits on the specified delimiter"
    # shellcheck disable=SC2034
    sample_s="a/b/c"
    assert equal "$(String.split sample_s "/")" "a b c"
  end
end

describe "String.chomp"
  it "leaves a non-whitespace-surrounded string alone"
    sample_s="abc"
    result_s="abc"
    String.chomp sample_s
    assert equal "$sample_s" "$result_s"
  end

  it "removes whitespace from the start of a string"
    sample_s="	abc"
    result_s="abc"
    String.chomp sample_s
    assert equal "$sample_s" "$result_s"
  end

  it "removes whitespace from the end of a string"
    sample_s="abc 	"
    result_s="abc"
    String.chomp sample_s
    assert equal "$sample_s" "$result_s"
  end

  it "removes whitespace from both ends  of a string"
    sample_s=" abc 	"
    result_s="abc"
    String.chomp sample_s
    assert equal "$sample_s" "$result_s"
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

describe "String.end_with?"
  it "affirms the positive"
    sample_s="a test"
    String.end_with? sample_s "t"
    assert equal $? 0
  end

  it "denies the negative"
    sample_s="a test"
    String.end_with? sample_s "r"
    assert equal $? 1
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
  end
end

describe "String.start_with?"
  it "affirms the positive"
  end

  it "denies the negative"
  end
end
