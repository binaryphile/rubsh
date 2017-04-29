Rubsh [![Build Status](https://travis-ci.org/binaryphile/rubsh.svg?branch=master)](https://travis-ci.org/binaryphile/rubsh)
=====

Enhanced data types for bash, inspired by Ruby - lovingly pronounced
"rubbish"

Features
--------

-   ruby-inspired apis for common objects

-   variables store object references

-   methods return objects, including arrays and hashes

-   chained method calls

-   ruby-inspired block syntax for functional-style methods (#each,
    #map)

-   a near-complete lack of dollar signs and quotation marks

-   a ruby-like DSL for creating classes using an actual object model
    with inheritance

-   economic use of bash's variable and function namespaces

-   interoperability with standard bash syntax

-   interactive `irbsh` shell

Requirements
------------

Bash 4.3+

Installation
------------

Clone and put `bin` and `lib` in your path, then use `source rubsh.bash`
in your scripts, or run `rubsh <script>` to run the script without the
need to source rubsh (ruby-style).

Usage
-----

You can run through the examples with `irbsh`.

### Output

    puts "hello, world!"

    > hello, world!

### String Creation

    String sample = "an example"
    puts sample

    > an example

Would be equivalent to `sample = String.new "an example"` in ruby, if
that were a thing.

### Array Creation

    Array samples = '( zero one )'
    puts samples

    > ([0]="zero" [1]="one")

### Hash Creation

    declare -A sampleh
    Hash sampleh = '( [zero]=0 [one]=1 )'
    puts sampleh

    > ([one]="1" [zero]="0" )

### Assignment

    String sample = "an example"
    sample = "a new hope"
    puts sample

    > a new hope

Requires that the object has been instantiated at least once so the bash
function (in this case, "sample") exists.

### Calling Methods

    Array samples = '( zero one )'
    puts samples .join -

    > zero-one

Method names are arguments and require a space between themselves and
the object name.

### Method Chaining

    Array samples = '( zero one )'
    puts samples .join { - } .upcase

    > ZERO-ONE

Method parameters must be braced for rubsh to know where the prior
method call ends.  Braces require surrounding spaces.

### Blocks

    declare -A sampleh
    Hash sampleh = '( [zero]=0 )'
    puts sampleh .map [ {k,v} '$k: $v' ]

    > ([0]="zero: 0")

Blocks use either one-line bracket syntax (shown here) or multiline
do/end syntax.  Parameter names are given between braces instead of
pipes.

The shown spacing is significant for both the brackets and braces.

For #map, the block body is an expression which is evaluated to a
string.  It uses single quotes to prevent variable expansion until
execution.

### Object Literals

    puts String "hello, world!" .upcase

    > HELLO, WORLD!

Object literals instantiate an object from a literal so methods can
immediately be called on them, much like ruby allows literals of basic
types to have methods called on them directly (e.g. "hello,
world!".upcase).

They create anonymous, single-use objects.

### Class Creation

    class Fruit; {
      def tasty? <<'  end'
        puts "Heck yeah!"
      end

      def fresh? <<'  end'
        puts "You bet."
      end
    }

    Fruit .new myfruit
    myfruit .fresh?

    > You bet.

Note the class statement ends with a semicolon before the opening brace.
Technically, the braces aren't required but provide a familiar visual
context.

### Inheritance

    class Banana : Fruit; {
      def fresh? <<'  end'
        puts "Not so much."
      end
    }

    Banana .new mybanana
    mybanana .fresh?

    > Not so much.

    mybanana .tasty?

    > Heck yeah!

Inheritance uses : rather than ruby's < to indicate the parent class.

### Introspection

    puts Array .class

    > "Class"

    puts Array .superclass

    > "Object"

    puts Array .ancestors

    > ([0]="Array" [1]="Object")

    puts Class .methods

    > ([0]="ancestors" [1]="declare" [2]="instance_methods" [3]="new" [4]="superclass" [5]="class" [6]="methods")

    puts Class .instance_methods false

    > ([0]="ancestors" [1]="declare" [2]="instance_methods" [3]="new" [4]="superclass")

Overview
--------

Bash, while powerful, has a frequently frustrating programming model.
Among other things, its combination of dynamic scoping, limited data
types and expansion-based command processing can make it tricky to learn
and difficult to accomplish complex tasks.

Fortunately, bash does a lot for you as well. If there is system
manipulation to be done on Unix, it can typically be done with bash, and
frequently with a minimum of (albeit strange) syntax. It's using bash
for logic rather than system manipulation where it tends to fall down.

While there are many ways bash could stand improvement, rubsh focuses on
one: making it easier to work with bash's built-in data types.

rubsh provides an object-model for those data types, including methods
and inheritance. rubsh doesn't offer more data types than the basic
string, array and hash (a.k.a. associative array) types, but it does
provide useful and intuitive methods for manipulating them.

It cribs as much of its organization from ruby's core libraries as
possible, making it easier to absorb, especially if you have ruby
experience. But it should also be fairly easy for anyone familiar with
general object-oriented concepts.

**NOTE**: So that it can use glob characters such as "?" in method
names, rubsh turns off bash globbing!  If you are using rubsh objects,
most of the time you won't miss it because rubsh selectively turns it on
an off as needed.  However, commands like `echo *` will only echo "*",
not the current directory contents as you would normally expect.  If you
need to enable globbing, do so with `set +f` (and turn it back off with
`set -f`).  Do not leave it on, however, or rubsh will not work
correctly!

How It Works
------------

Rubsh provides some basic classes:

-   **String** - self-explanatory

-   **Array** - some sorely-needed standard functions for manipulating
    lists of strings

-   **Hash** - associative array manipulation

Rubsh doesn't change the underlying data types, so for example, hashes
can still only store strings as values, but the methods available to
manipulate them are new with rubsh.

Each class is actually a bash function. According to the ruby convention
for class names, they are all capitalized as shown above.

These classes are used to create "object" instances, which correspond to
individual variables you might use in your script. The objects
themselves are also simply bash functions, created for you by rubsh.

The first argument to an object (i.e. function) is usually the name of a
method. While method names are just normal string arguments, for the
sake of similarity to ruby syntax, they are supplied with a leading dot:

    Array .new <arguments>

Because Array is a function, the method name is separated by a space so
that it is the first argument to the function. In this case, the \#new
method creates a new object instance of the Array class. This roughly
corresponds to ruby's `Array.new`

Naturally, in order for rubsh to work, its functions need to be the
first word in the command line. This dictates some differences from
ruby's syntax.

For example, ruby would normally assign the result of \#new to a
variable:

    myarray = Array.new

You would then call a method such as \#join on the myarray object.

rubsh needs Array to be first on the command line, so it turns the syntax
around a bit by necessity:

    Array myarray = <initializer>

This is an unorthodox call to Array\#new, but it is still a method call.
This is one of the cases where rubsh does some magic to infer the method
from the syntax.

rubsh's Array\#new does two things. First, it creates a bash array
variable named myarray. Second, it creates a bash function, also called
myarray.

The array variable stores the given array, just like any other bash
variable would. It can be used with all the usual bash functions and
expansions for arrays.

The function is rubsh's contribution. The myarray function represents the
object instance of the Array class. It's what responds to Array methods:

    puts myarray .join -

myarray, the function, knows how to respond to Array's methods. When it
needs to determine the array on which it should operate, it uses
myarray, the variable. Unsurprisingly, changing the myarray variable's
contents (say, by normal bash assignment) changes the values used by the
function.

Scoping
-------

The scope of the myarray variable (local to the current function or
global) depends on a couple things.

If the variable myarray existed when \#new was called, then its existing
scope remains in effect. This way you can directly control the scope
with your own declaration prior to calling \#new.

Otherwise the variable is created globally by default. This may be what
you want, in which case the normal invocation is fine.

Global scoping may not always be what you want, however. You may declare
the variable local yourself:

    local myarray
    Array myarray = '( zero one )'

However there is another, more compact alternative for local declaration
instead:

    $(Array myarray := '( zero one )')

The colon-equals sign calls Array\#declare, which generates a compound
statement on stdout. The statement declares the variable as local, and
also instantiates the object. The statement is captured and executed by
the bash shell substitution `$()`.

Of course, bash throws one special case at us.  bash requires explicit
declaration for hashes.

To create a hash variable, you should declare the variable yourself
before instantiating the object.  Here is how you declare a global hash
variable:

    declare -Ag myhash
    Hash myhash = '( [zero]=0 )'

Drop the -g and you have a locally scoped myhash (you can use the
`local` builtin, but `declare` works too).

If you want a local hash, however, the (syntactically sugared) #declare
method is the least verbose:

    $(Hash myhash := '( [zero]=0 )')

This way the hash doesn't need a separate declaration at all. Bear in
mind that this method only works for local declarations though.

Keywords
--------

-   **`require`** *`<feature_name>`* - load rubsh features

    Much like ruby's keyword, `require` can load files with or without
    extension and with or without specific paths.  Paths are relative to
    the current working directory of the script.

    Features not specified by path are searched for on the environment
    variable `RUBSH_PATH`, which is initialized to rubsh's own
    directory, as well as the `.` current directory.

    Features not specified by extension are searched for with the
    following extensions, in order:

    -   no extension
    -   `.rubsh`
    -   `.bash`
    -   `.sh`

-   **`require_relative`** *`<feature_name>`* - load rubsh features
    relative to the current source file

    Works the same as `require`, but relative to the file from which it
    is called.

Conclusion
----------

There are a number of other useful features which make rubsh quite
pleasurable to work with over standard bash. I invite you to read the
test suite to learn more.
