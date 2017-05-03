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

-   ruby-inspired block syntax for functional-style methods
    (\#each, \#map)

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
method call ends. Braces require surrounding spaces.

### Blocks

    declare -A sampleh
    Hash sampleh = '( [zero]=0 )'
    puts sampleh .map [ {k,v} '$k: $v' ]

    > ([0]="zero: 0")

Blocks use either one-line bracket syntax (shown here) or multiline
do/end syntax. Parameter names are given between braces instead of
pipes.

The shown spacing is significant for both the brackets and braces.

For \#map, the block body is an expression which is evaluated to a
string. It uses single quotes to prevent variable expansion until
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

Inheritance uses : rather than ruby's &lt; to indicate the parent class.

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
names, rubsh turns off bash globbing! If you are using rubsh objects,
most of the time you won't miss it because rubsh selectively turns it on
an off as needed. However, commands like `echo *` will only echo "\*",
not the current directory contents as you would normally expect. If you
need to enable globbing, do so with `set +f` (and turn it back off with
`set -f`). Do not leave it on, however, or rubsh will not work
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

rubsh needs Array to be first on the command line, so it turns the
syntax around a bit by necessity:

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

The function is rubsh's contribution. The myarray function represents
the object instance of the Array class. It's what responds to Array
methods:

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

Of course, bash throws one special case at us. bash requires explicit
declaration for hashes.

To create a hash variable, you should declare the variable yourself
before instantiating the object. Here is how you declare a global hash
variable:

    declare -Ag myhash
    Hash myhash = '( [zero]=0 )'

Drop the -g and you have a locally scoped myhash (you can use the
`local` builtin, but `declare` works too).

If you want a local hash, however, the (syntactically sugared) \#declare
method is the least verbose:

    $(Hash myhash := '( [zero]=0 )')

This way the hash doesn't need a separate declaration at all. Bear in
mind that this method only works for local declarations though.

Keywords
--------

-   **`require`** *`<feature_name>`* - load rubsh features

    Much like ruby's keyword, `require` can load files with or without
    extension and with or without specific paths. Paths are relative to
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

Design
------

Rubsh attempts to faithfully translate a few core features from ruby
into bash.

Of course, not everything needs to be recreated because bash has many of
the basics implemented by ruby already, albeit in bash's way not ruby's.
For example, bash already handles low-level allocation of memory, as
well as most parsing.

What can't be handled ruby's way can be faked fairly well in a number of
cases. For example, if some ruby-like syntax doesn't exist in bash's
parser, a function can usually let rubsh do the parsing itself. In order
to use a function, all that is necessary is that the syntax allows rubsh
to specify the function name as the first item in the command, and
everything else on the line will be interpreted as arguments to the
function (except special bash tokens such as semicolon or the
redirection operators, so these are avoided).

The primary design features of ruby targeted by rubsh include:

-   reference variables

-   capitalized constants (sorta)

-   objects

-   instance variables

-   classes

-   singleton classes (a.k.a. metaclasses or eigenclasses)

-   methods

-   class methods

-   class variables

That means some big features are left out, of course, notably:

-   constants which are actually constant

-   nested constants

-   nested classes

-   modules, nested or otherwise

-   scopes

-   iterators

-   Procs

-   etc.

### Reference Variables

Variables in ruby, whether they are local, instance, class or global,
store one thing and that's objects. More specifically, they store
references to objects. That's so an object can be referenced by more
than one variable, and each variable has the same access to that object.
The object doesn't care what particular variable is used to send
messages (method calls) to it, just that the variable knows where it is.

Bash variables are different. They are strictly values. Although bash
offers structured data types such as arrays and hashes, which have some
of the characteristics of ruby arrays and hashesand , the big difference
is that bash variables aren't shareable by reference (at least, through
normal usage, although you can do indirection in bash). If you have two
bash variables with the same content, they are each their own copy.

In order to get around this, when rubsh uses actual bash variables, the
actual value stored is an id for an object, not a normal value. How the
objects are structured to use this id is discussed a bit further below.
However, the ids themselves are simple. In the case of classes, which
have names assigned as constants, the id is the snake-case version of
the name, such as `my_class` for `MyClass`. These have the advantage of
being easy to use internally for all of the predefined classes, since
they can be easily hardcoded. For normal objects, the ids are simply
unique integers, allocated by the function `__next_id`. Objects don't
have constant names and so can't be identified the same way as classes.

When rubsh's internal functions use those variables, there are usually
two levels of indirection. I wanted rubsh's variable syntax to more
closely resemble that of ruby's, where it is sufficient to use the
variable's name to get at the object which it references. In bash, you
have to expand the variable to get at its contents using the dollar-sign
notation. That's because all arguments in bash are string literals, so
variables are expanded before being passed to functions. Therefore, in
order to not have dollar-sign expansion everywhere, rubsh expects the
names of variables as (string-literal) arguments. Rubsh explicitly
expands the variable names itself.

A second level of indirection happens at that point, since the rubsh
function only has a variable name by then. The variable's contents
should be an object id, as discussed above, such as `my_class` or `21`.
Rubsh then refers to that id when accessing the object itself.

As a side note on constants, while rubsh doesn't treat constants
(capitalized variables) as unchangeable like ruby would, it does use the
capitalization to know how to look up and treat constants in other
respects (stored as class names, etc.).

### Objects

In ruby, everything is an object. Every object has a basic shared
structure with some meta-information, and values stored in instance
variables. Objects also have a class, which in turn has an inheritance
hierarchy. Methods are "sent" to the object by calling one if the
object's reference variables with the method name, tacked onto the
variable name with a ".".

Rubsh emulates most of this. Objects in rubsh have some of the ruby
metadata, enough to allow inheritance and the object model to function.
Unlike ruby, which stores individual structs of metadata corresponding
to individual objects, rubsh usually consolidates any given field of
metadata into a single hash for all objects. For example, instead of
storing the object's class in a struct for that object, the classes for
all objects are stored in a hash called `__classh`. All internal rubsh
variables start with two underscores (so the "\_\_" namespace is
reserved), and the terminal h is for "hash". The object's id is the
index into the hash. As usual, hashes can only store string values, so
any more complex metadata are stored in their own standalone array or
hash variables with their own ids, and those ids are stored in a hash
indexed by the object id.

Some metadata are used to keep track of a list of objects, such as the
`__classesh` hash, which tracks the defined class objects by id. Because
it is frequently used to test for the existence of an id, a hash is used
instead of an array. This way a key can easily (and quickly) be tested
for with the `-z` and `-n` boolean operators, e.g. with
`[[ -z ${__classesh[$id]:-} ]]`. The value stored at the key is never
used, so it is usually set to "1" arbitrarily. Using hash keys for this
purpose should scale well. Additionally, an actual list of the keys can
easily be generated with the expression `${!__classesh[@]}`, allowing
simple for loops.

Basic object metadata include:

-   `__classh` - class of an object (by object id)

-   `__typeh` - shortcut for the basic types of:

    -   `array` - array objects, ditto
    -   `class` - classes
    -   `false` - boolean false
    -   `hash` - hash objects, ditto
    -   `nil` - nil
    -   `object` - instances of classes
    -   `string` - string objects, as distinct from bash strings
    -   `true` - boolean true

-   `__ivarh` - instance variable ids (by `<objectid>@<variable_name>`)

Classes include the following, in addition to the basic metadata:

-   `__<classid>_methodsh` - instance methods of an class (by
    method name)

-   `__method_bodyh` - hash of method bodies (by
    `<classid>#<method_name>`)

-   `__singletonh` - true if class is singleton (by class id)

-   `__superh` - superclass of a class object (by class id)

Other data:

-   `__classesh` - defined classes (by class id)

-   `__constanth` - object ids (by constant name)

-   `__stringh` - string values (by object id)

Array and hash values are stored directly in variables, since they can't
be stored in hashes.  The variable name is the object id in this case.

#### Class

The `__classh` hash returns the class id of the object.  The key is the
object id.

#### Types

The `__typeh` hash returns the type of object by the object id (class
ids are just object ids as well). This is used to tell what other
metadata is available.  It could be determined by a two-step process of
looking up the object then the class, but storing it here reduces the
number of lookups to one, and is safe since the type won't change (ruby
does this as well).

`class` and `object` are basic types. `class` is for classes, both
builtin and user-defined. `object` is for instances of classes other
than strings, arrays and hashes. Mostly these are user-defined objects,
although there are other objects defined by rubsh, such as the top-level
`self` object.

`string`, `array` and `hash` are data types, even though they are
objects like the any other class instance.  However, they have ids which
point directly to their values (in `__stringh` or the variable names
themselves for array and hash).

`nil`, `true` and `false` are special types because they don't have
corresponding objects, they are simply taken to be the values
themselves once the type is known.

#### Instance Variables

`__ivarh` stores object ids for the instance variables of an object.  To
get to the object id stored by the variable, you need to supply a key
`<objectid@variable_name>`.  The "@" sign matches the variable naming
used by ruby, so the key is specified by appending the variable name to
the objectid without having to add the "@" since it's already in the
variable name.

If the object is a singleton class, then the variable has double "@"s
instead of single, so the key is `<objectid@@variable_name>` in that
case.  The same hash is used to store both class and instance variables.

#### Class Methods List

There are per-class hashes, named for each class as
`__<classid>_methodsh`.  This is so a list of methods for a class can be
generated by a single expression `${!__<classid>_methodsh[@]}`.
Membership in the key list is easily tested with `-z` or `-n`, e.g. `[[
-n ${__<classid>_methodsh[method_name]:-} ]]`.

#### Method Bodies

The bodies of methods are stored as strings and evaluated when called.

The bodies are held in the `__method_bodyh` hash and are indexed by
`<classid>#<method_name>`, according to the ruby notation for instance
methods.  The "#" is not part of the method name and is added manually.

#### Singleton Classes

The `__singletonh` hash contains the class ids of the classes which are
singletons.  The values are simply ones.

#### Superclasses

The `__superh` hash contains the class id of the superclass of the
supplied class id.  All classes have a superclass, except for "Object",
which has an entry but an empty value of "".

#### Defined Classes

All defined classes have a class id key in `__classesh`, with a value of
one.

#### Constants

The object ids pointed to by constants are stored in `__constanth` by
the constant name (capitalized form).

#### Variable Values

String variables values are held (by object id) in the `__stringh` hash.

Array and hash variables are held in regular bash variables.  The names
of the variables are the object ids.  In the case of these objects,
however, the id format is modified to include two leading underscores.
The ids are considered to include the underscores so bash variables
storing them can be dereferenced without modification.

Conclusion
----------

There are a number of other useful features which make rubsh quite
pleasurable to work with over standard bash. I invite you to read the
test suite to learn more.
