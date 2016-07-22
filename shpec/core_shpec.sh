#!/usr/bin/env bash

library=../lib/core.sh
source "${BASH_SOURCE%/*}/$library" 2>/dev/null || source "$library"
unset -v library

init() {
  _rubsh.IO.puts "$(mktemp --directory)"
}

cleanup() {
  validate_dirname "$1"
  rm -rf -- "$1"
}

validate_dirname() {
  [[ $1 =~ ^/tmp/tmp\. ]]   || exit
  [[ -d $1 ]]               || exit
}

describe "_rubsh.Array.to_s"
  it "renders a string version of an array"
    (
    # shellcheck disable=SC2034
    sample=( "a" "b" "c" )
    # shellcheck disable=SC2034
    expected='("a" "b" "c")'
    # shellcheck disable=SC2034
    result="$(_rubsh.Array.to_s sample)"
    assert equal "$expected" "$result"
    )
  end
end

describe "_rubsh.core.alias"
  it "aliases String.blank? function to core"
    (
    # shellcheck disable=SC2034
    aliases=( "blank?" )
    _rubsh.core.alias String aliases
    # shellcheck disable=SC2034
    blank=""
    String.blank? blank
    assert equal $? 0
    )
  end
end

describe "_rubsh.File.basename"
  it "finds the base name of a file by reference"
    (
    # shellcheck disable=SC2034
    sample=/home/gumby/work/ruby.rb
    result="$(_rubsh.File.basename sample)"
    assert equal "$result" "ruby.rb"
    )
  end

  it "finds the base name of a file by value"
    (
    # shellcheck disable=SC2034
    sample=/home/gumby/work/ruby.rb
    result="$(_rubsh.File.basename "$sample")"
    assert equal "$result" "ruby.rb"
    )
  end

  it "finds the base name of trailing slash by reference"
    (
    # shellcheck disable=SC2034
    sample=/home/gumby/work/ruby.rb/
    result="$(_rubsh.File.basename sample)"
    assert equal "$result" "ruby.rb"
    )
  end

  it "finds the base name of a trailing slash by value"
    (
    # shellcheck disable=SC2034
    sample=/home/gumby/work/ruby.rb/
    result="$(_rubsh.File.basename "$sample")"
    assert equal "$result" "ruby.rb"
    )
  end
end

describe "_rubsh.File.dirname"
  it "determines the directory name with multiple components by reference"
    (
    sample="/home/gumby/work/ruby.rb"
    assert equal "$(_rubsh.File.dirname sample)" "/home/gumby/work"
    )
  end

  it "determines the directory name without components by reference"
    (
    sample="ruby.rb"
    assert equal "$(_rubsh.File.dirname sample)" "."
    )
  end

  it "determines the directory name with multiple components by value"
    (
    sample="/home/gumby/work/ruby.rb"
    assert equal "$(_rubsh.File.dirname "$sample")" "/home/gumby/work"
    )
  end

  it "determines the directory name without components by value"
    (
    sample="ruby.rb"
    assert equal "$(_rubsh.File.dirname "$sample")" "."
    )
  end
end

describe "_rubsh.File.realpath"
  it "determines the directory name with multiple components without symlinks or dots by reference"
    (
    temp="$(init)"
    validate_dirname "$temp"
    mkdir "$temp"/dir2
    touch "$temp"/dir2/file
    ln -sf dir2 "$temp"/dir
    sample="$temp"/../.."$temp"/dir/file
    assert equal "$(_rubsh.File.realpath sample)" "$temp"/dir2/file
    cleanup "$temp"
    )
  end

  it "determines the directory name with multiple components without symlinks or dots by value"
    (
    temp="$(init)"
    validate_dirname "$temp"
    mkdir "$temp"/dir2
    touch "$temp"/dir2/file
    ln -sf dir2 "$temp"/dir
    sample="$temp"/../.."$temp"/dir/file
    assert equal "$(_rubsh.File.realpath "$sample")" "$temp"/dir2/file
    cleanup "$temp"
    )
  end
end

describe "_rubsh.IO.printf"
  it "printfs to stdout"
    (
    sample="test"
    assert equal "$(_rubsh.IO.printf "%s\n" "$sample")" "$(printf "%s\n" "$sample")"
    )
  end
end

describe "_rubsh.IO.puts"
  it "puts to stdout by value"
    (
    sample="test"
    assert equal "$(_rubsh.IO.puts "$sample")" "$(printf "%s\n" "$sample")"
    )
  end

  it "puts to stdout by reference"
    (
    sample="test"
    assert equal "$(_rubsh.IO.puts sample)" "$(printf "%s\n" "$sample")"
    )
  end
end

describe "_rubsh.Shell.alias_function"
  it "aliases a function"
    (
    sample() { echo "hello"; }
    _rubsh.Shell.alias_function sample2 sample
    assert equal "$(sample2)" "hello"
    )
  end
end

describe "_rubsh.Shell.class"
  it "reports if it is an array"
    (
    # shellcheck disable=SC2034
    sample=( 1 2 3 )
    assert equal "$(_rubsh.Shell.class sample)" "array"
    )
  end

  it "reports if it is a string"
    (
    # shellcheck disable=SC2034
    sample="value"
    assert equal "$(_rubsh.Shell.class sample)" "string"
    )
  end
end

describe "_rubsh.Shell.dereference"
  it "dereferences a scalar variable"
    (
    # shellcheck disable=SC2034
    sample="text sample"
    # shellcheck disable=SC2034
    indirect="sample"
    _rubsh.Shell.dereference indirect
    assert equal "$indirect" "text sample"
    )
  end

  it "dereferences an array variable"
    (
    # shellcheck disable=SC2034
    sample=( "testing" "one" "two" )
    # shellcheck disable=SC2034
    indirect="sample"
    _rubsh.Shell.dereference indirect
    assert equal "$(_rubsh.Shell.class indirect)" "array"
    assert equal "${#indirect[@]}" 3
    assert equal "${indirect[*]}" "testing one two"
    )
  end
end

describe "_rubsh.Shell.variable?"
  it "detects a variable"
    (
    sample="test"
    _rubsh.Shell.variable? sample
    assert equal $? 0
    )
  end

  it "doesn't detect a function"
    (
    sample2() { echo hello ;}
    _rubsh.Shell.variable? sample2
    assert equal $? 1
    )
  end

  it "doesn't detect an undefined variable"
    (
    _rubsh.Shell.variable? no_var
    assert equal $? 1
    )
  end
end

describe "_rubsh.Shell.value"
  it "returns a scalar value"
    (
    # shellcheck disable=SC2034
    sample="value text"
    assert equal "$(_rubsh.Shell.value sample)" "$sample"
    )
  end

  it "returns an array value"
    (
    # shellcheck disable=SC2034
    sample=( "one" "two" "three" )
    assert equal "$(_rubsh.Shell.value sample)" "${sample[*]} "
    )
  end
end

describe "_rubsh.String.blank?"
# TODO: fail undefined test
  it "checks for empty string"
    (
    # shellcheck disable=SC2034
    sample=""
    _rubsh.String.blank? sample
    assert equal $? 0
    )
  end

  it "checks for string with only spaces"
    (
    # shellcheck disable=SC2034
    sample=" "
    _rubsh.String.blank? sample
    assert equal $? 0
    )
  end

  it "checks for string with only tabs"
    (
    # shellcheck disable=SC2034
    sample=" 	"
    _rubsh.String.blank? sample
    assert equal $? 0
    )
  end

  it "doesn't match strings with characters"
    (
    # shellcheck disable=SC2034
    sample="ab "
    _rubsh.String.blank? sample
    assert equal $? 1
    )
  end
end

describe "_rubsh.String.chomp"
  it "leaves a non-whitespace-surrounded string alone"
    (
    sample="abc"
    result="abc"
    _rubsh.String.chomp sample
    assert equal "$sample" "$result"
    )
  end

  it "removes whitespace from the start of a string"
    (
    sample="	abc"
    result="abc"
    _rubsh.String.chomp sample
    assert equal "$sample" "$result"
    )
  end

  it "removes whitespace from the end of a string"
    (
    sample="abc 	"
    result="abc"
    _rubsh.String.chomp sample
    assert equal "$sample" "$result"
    )
  end

  it "removes whitespace from both ends  of a string"
    (
    sample=" abc 	"
    result="abc"
    _rubsh.String.chomp sample
    assert equal "$sample" "$result"
    )
  end
end

describe "_rubsh.String.end_with?"
  it "affirms the positive"
    (
    sample="a test"
    _rubsh.String.end_with? sample "t"
    assert equal $? 0
    )
  end

  it "denies the negative"
    (
    sample="a test"
    _rubsh.String.end_with? sample "r"
    assert equal $? 1
    )
  end
end

describe "_rubsh.String.eql?"
  it "checks equality"
    (
    # shellcheck disable=SC2034
    sample="abc"
    _rubsh.String.eql? sample "$sample"
    assert equal $? 0
    )
  end

  it "fails inequality"
    (
    # shellcheck disable=SC2034
    sample="abc"
    _rubsh.String.eql? sample ""
    assert equal $? 1
    )
  end
end

describe "_rubsh.String.start_with?"
  it "affirms the positive"
    (
    sample="a test"
    _rubsh.String.start_with? sample "a"
    assert equal $? 0
    )
  end

  it "denies the negative"
    (
    sample="a test"
    _rubsh.String.start_with? sample "r"
    assert equal $? 1
    )
  end
end
