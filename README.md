[TOC]

# Rubsh

Ruby-inspired datatype enhancements for bash - pronounced "rubbish"

Rubsh is a trashy attempt at making bash scripting a bit more ruby-ish.

When sourced, rubsh adds a set of functions to your bash environment
that allow you to do ruby-like operations with data types.  The
underlying bash semantics are unchanged, so you can mix rubsh with
regular bash and make your scripting just a bit rubbish.  Or you can go
full rubsh, which will make it look a bit more like ruby and just
confuse the hell out of bashers and rubyists alike.

This library is for you if you like watching people's heads explode.

Why?  Bash is pretty annoying, but it's really good at system-level
manipulation and it's on every platform.  Rubsh makes it just slightly
less annoying to work with.

## Some interactive examples

~~~bash
> source rubsh.sh
> new my_string = String.new " hello there " # Declare a String surrounded by spaces
> echo $(my_string.class)
String
> echo $my_string
 hello there
> my_string.chomp # Trim the surrounding spaces
> echo $my_string
hello there
> if my_string.start_with? "h"; then echo "True!"; fi
True!
> new result = my_string.split
> echo $(result.class)
Array
> echo $(result.to_s)
'("hello" "there")'
> echo $(result.join " ")
hello there
~~~

## Using rubsh in a script

~~~bash
#!/usr/bin/env bash

# Source rubsh.  Provide the relative path from this script.  This
# expression makes sure rubsh gets sourced properly even if you run the
# script from a location outside its directory.

rubsh=../rubsh/lib/rubsh.sh
source "${BASH_SOURCE%/*}/$rubsh" 2>/dev/null || source "$rubsh"

[...do rubbishy stuff...]
~~~
