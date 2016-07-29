#!/usr/bin/env bash

library=../lib/core.sh
source "${BASH_SOURCE%/*}/$library" 2>/dev/null || source "$library"
unset -v library

init() {
  result=$(mktemp --directory) || exit
  _rubsh.IO.puts "$result"
}

cleanup() {
  validate_dirname "$1" || exit
  rm -rf -- "$1"
}

validate_dirname() { [[ $1 == /tmp/tmp.* && -d $1 ]] ;}

describe "_rubsh.Array.inspect"
  it "renders a literal of an array"
    (
    # shellcheck disable=SC2034
    sample=( "a" "b" "c" )
    # shellcheck disable=SC2034
    result="$(_rubsh.Array.inspect :sample)"
    assert equal "$result" '("a" "b" "c")'
    )
  end
end

describe "_rubsh.Array.to_s"
  it "renders a string concatenation of an array"
    (
    # shellcheck disable=SC2034
    sample=( "a" "b" "c" )
    # shellcheck disable=SC2034
    result="$(_rubsh.Array.to_s :sample)"
    assert equal "$result" "a b c"
    )
  end
end

describe "_rubsh.core.alias"
  it "aliases String.blank? function to core"
    (
    # shellcheck disable=SC2034
    aliases=( ":blank?" )
    _rubsh.core.alias :String :aliases
    # shellcheck disable=SC2034
    blank=""
    String.blank? :blank
    assert equal $? 0
    )
  end
end

describe "_rubsh.core.alias_method"
  it "aliases a class method to a variable"
    (
    sample=""
    _rubsh.core.alias_method :sample :chomp :_rubsh.String
    sample.chomp
    assert equal $? 0
    )
  end
end

describe "_rubsh.File.basename"
  it "finds the base name of a file by reference"
    (
    # shellcheck disable=SC2034
    sample=/home/gumby/work/ruby.rb
    result="$(_rubsh.File.basename :sample)"
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
    result="$(_rubsh.File.basename :sample)"
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
    assert equal "$(_rubsh.File.dirname :sample)" "/home/gumby/work"
    )
  end

  it "determines the directory name without components by reference"
    (
    sample="ruby.rb"
    assert equal "$(_rubsh.File.dirname :sample)" "."
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
    validate_dirname "$temp" || exit
    mkdir "$temp"/dir2
    touch "$temp"/dir2/file
    ln -sf dir2 "$temp"/dir
    sample="$temp"/../.."$temp"/dir/file
    assert equal "$(_rubsh.File.realpath :sample)" "$temp"/dir2/file
    cleanup "$temp"
    )
  end

  it "determines the directory name with multiple components without symlinks or dots by value"
    (
    temp="$(init)"
    validate_dirname "$temp" || exit
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
  it "printfs to stdout by value"
    (
    sample=test
    assert equal "$(_rubsh.IO.printf "%s\n" "$sample")" "$(printf "test\n")"
    )
  end

  it "printfs to stdout by reference"
    (
    sample=test
    assert equal "$(_rubsh.IO.printf "%s\n" :sample)" "$(printf "test\n")"
    )
  end

  it "printfs to stdout by references"
    (
    sample=test
    # shellcheck disable=SC2034
    sample_format="%s\n"
    assert equal "$(_rubsh.IO.printf :sample_format :sample)" "$(printf "test\\\n")"
    )
  end

  # it "printfs to stdout with an arbitrary number of references"
  #   (
  #   sample=testing
  #   # shellcheck disable=SC2034
  #   sample2=one
  #   # shellcheck disable=SC2034
  #   sample3=two
  #   # shellcheck disable=SC2034
  #   sample_format="%s %s %s\n"
  #   assert equal "$(_rubsh.IO.printf :sample_format :sample :sample2 :sample3)" "$(printf "testing one two\\\n")"
  #   )
  # end
end

describe "_rubsh.IO.puts"
  it "puts to stdout by value"
    (
    sample=test
    assert equal "$(_rubsh.IO.puts "$sample")" "$(printf "test\n")"
    )
  end

  it "puts to stdout by reference"
    (
    sample=test
    assert equal "$(_rubsh.IO.puts :sample)" "$(printf "test\n")"
    )
  end
end

describe "_rubsh.Shell.alias_function"
  it "aliases a function"
    (
    sample() { echo "hello"; }
    _rubsh.Shell.alias_function :sample2 :sample
    assert equal "$(sample2)" "hello"
    )
  end
end

describe "_rubsh.Shell.assign_literal"
  it "assigns a string literal to a variable"
    (
    sample=""
    _rubsh.Shell.assign_literal :sample "value"
    assert equal "$(_rubsh.Shell.class :sample)" "string"
    assert equal "$sample" "value"
    )
  end

  it "assigns an array literal to a variable"
    (
    sample=""
    _rubsh.Shell.assign_literal :sample '("one" "two" "three")'
    assert equal "$(_rubsh.Shell.class :sample)" "array"
    assert equal "${sample[*]}" "one two three"
    )
  end
end

describe "_rubsh.Shell.class"
  it "reports if it is an array"
    (
    # shellcheck disable=SC2034
    sample=( 1 2 3 )
    assert equal "$(_rubsh.Shell.class :sample)" "array"
    )
  end

  it "reports if it is a string"
    (
    # shellcheck disable=SC2034
    sample="value"
    assert equal "$(_rubsh.Shell.class :sample)" "string"
    )
  end

  it "errors if it is not a variable"
    (
    _rubsh.Shell.class :sample
    assert equal $? 1
    )
  end
end

describe "_rubsh.Shell.dereference"
  it "dereferences a scalar variable"
    (
    # shellcheck disable=SC2034
    sample="some text"
    # shellcheck disable=SC2034
    indirect=":sample"
    _rubsh.Shell.dereference :indirect
    assert equal "$(_rubsh.Shell.class :indirect)" "string"
    assert equal "$indirect" "some text"
    )
  end

  it "dereferences an array variable"
    (
    # shellcheck disable=SC2034
    sample=( "testing" "one" "two" )
    # shellcheck disable=SC2034
    indirect=":sample"
    _rubsh.Shell.dereference :indirect
    assert equal "$(_rubsh.Shell.class :indirect)" "array"
    assert equal "${#indirect[@]}" 3
    assert equal "${indirect[*]}" "testing one two"
    )
  end
end

describe "_rubsh.Shell.inspect"
  it "returns a literal string representation"
    (
    # shellcheck disable=SC2034
    sample="value text"
    assert equal "$(_rubsh.Shell.inspect :sample)" "value text"
    )
  end

  it "returns a literal array representation"
    (
    # shellcheck disable=SC2034
    sample=( "one" "two" "three" )
    assert equal "$(_rubsh.Shell.inspect :sample)" '("one" "two" "three")'
    )
  end
end

describe "_rubsh.Shell.passback_as"
  it "returns a single value in a variable"
    (
    func() { _rubsh.Shell.passback_as :sample "example text" ;}
    sample=""
    func
    assert equal "$sample" "example text"
    )
  end
end

describe "_rubsh.Shell.symbol?"
  it "detects a variable"
    (
    _rubsh.Shell.symbol? :sample
    assert equal $? 0
    )
  end

  it "doesn't detect a string"
    (
    _rubsh.Shell.symbol? sample
    assert equal $? 1
    )
  end
end

describe "_rubsh.Shell.to_s"
  it "returns a string"
    (
    # shellcheck disable=SC2034
    sample="value text"
    assert equal "$(_rubsh.Shell.to_s :sample)" "value text"
    )
  end

  it "returns a concatenated string"
    (
    # shellcheck disable=SC2034
    sample=( "one" "two" "three" )
    assert equal "$(_rubsh.Shell.to_s :sample)" "one two three"
    )
  end
end

describe "_rubsh.Shell.variable?"
  it "detects a variable"
    (
    sample=test
    _rubsh.Shell.variable? :sample
    assert equal $? 0
    )
  end

  it "doesn't detect a function"
    (
    sample2() { echo hello ;}
    _rubsh.Shell.variable? :sample2
    assert equal $? 1
    )
  end

  it "doesn't detect an undefined variable"
    (
    _rubsh.Shell.variable? :no_var
    assert equal $? 1
    )
  end
end

describe "_rubsh.String.blank?"
# TODO: fail undefined test
  it "checks for empty string"
    (
    # shellcheck disable=SC2034
    sample=""
    _rubsh.String.blank? :sample
    assert equal $? 0
    )
  end

  it "checks for string with only spaces"
    (
    # shellcheck disable=SC2034
    sample=" "
    _rubsh.String.blank? :sample
    assert equal $? 0
    )
  end

  it "checks for string with only tabs"
    (
    # shellcheck disable=SC2034
    sample=" 	"
    _rubsh.String.blank? :sample
    assert equal $? 0
    )
  end

  it "doesn't match strings with characters"
    (
    # shellcheck disable=SC2034
    sample="ab "
    _rubsh.String.blank? :sample
    assert equal $? 1
    )
  end
end

describe "_rubsh.String.chomp"
  it "leaves a non-whitespace-surrounded string alone"
    (
    sample="abc"
    _rubsh.String.chomp :sample
    assert equal "$sample" "abc"
    )
  end

  it "removes whitespace from the start of a string"
    (
    sample="	abc"
    _rubsh.String.chomp :sample
    assert equal "$sample" "abc"
    )
  end

  it "removes whitespace from the end of a string"
    (
    sample="abc 	"
    _rubsh.String.chomp :sample
    assert equal "$sample" "abc"
    )
  end

  it "removes whitespace from both ends of a string"
    (
    sample=" abc 	"
    _rubsh.String.chomp :sample
    assert equal "$sample" "abc"
    )
  end
end

describe "_rubsh.String.end_with?"
  it "affirms the positive"
    (
    sample="a test"
    _rubsh.String.end_with? :sample "t"
    assert equal $? 0
    )
  end

  it "denies the negative"
    (
    sample="a test"
    _rubsh.String.end_with? :sample "r"
    assert equal $? 1
    )
  end
end

describe "_rubsh.String.eql?"
  it "checks equality"
    (
    # shellcheck disable=SC2034
    sample="abc"
    _rubsh.String.eql? :sample "abc"
    assert equal $? 0
    )
  end

  it "fails inequality"
    (
    # shellcheck disable=SC2034
    sample="abc"
    _rubsh.String.eql? :sample ""
    assert equal $? 1
    )
  end
end

describe "_rubsh.String.inspect"
  it "returns a string literal expression for a variable"
    (
    sample="one"
    assert equal "$(_rubsh.String.inspect :sample)" "one"
    )
  end
end

describe "_rubsh.String.new"
  it "adds string methods to a variable"
    (
    sample=""
    _rubsh.String.new :sample
    sample.blank?
    assert equal $? 0
    )
  end
end

describe "_rubsh.String.start_with?"
  it "affirms the positive"
    (
    sample="a test"
    _rubsh.String.start_with? :sample "a"
    assert equal $? 0
    )
  end

  it "denies the negative"
    (
    sample="a test"
    _rubsh.String.start_with? :sample "r"
    assert equal $? 1
    )
  end
end

describe "_rubsh.String.to_s"
  it "returns a string for a variable by reference"
    (
    sample="one"
    assert equal "$(_rubsh.String.to_s :sample)" "one"
    )
  end
end

describe "_rubsh.Symbol.to_s"
  it "returns a string for a symbol literal"
    assert equal "$(_rubsh.Symbol.to_s :sample)" "sample"
  end

  it "errors on a non-symbol literal with no initial colon"
    _rubsh.Symbol.to_s "sample" >/dev/null
    assert equal $? 1
  end

  it "errors on a non-symbol literal with a semicolon"
    _rubsh.Symbol.to_s "sample;" >/dev/null
    assert equal $? 1
  end

  it "errors on a non-symbol literal with a bracket"
    _rubsh.Symbol.to_s "sample]" >/dev/null
    assert equal $? 1
  end
end
