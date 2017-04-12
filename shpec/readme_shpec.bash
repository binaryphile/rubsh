source import.bash

shpec_helper_imports=(
  initialize_shpec_helper
  shpec_cwd
  stop_on_error
)
eval "$(importa shpec-helper shpec_helper_imports)"
initialize_shpec_helper
stop_on_error=true
stop_on_error

source "$(shpec_cwd)"/../lib/rubsh.bash

describe README
  it "Output"; (
    _shpec_failures=0
    assert equal "hello, world!" "$(puts "hello, world!")"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "String Creation"; (
    _shpec_failures=0
    String sample = "an example"
    assert equal "an example" "$(puts sample)"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "Array Creation"; (
    _shpec_failures=0
    Array samples = '( zero one )'
    assert equal '([0]="zero" [1]="one")' "$(puts samples)"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "Hash Creation"; (
    _shpec_failures=0
    declare -A sampleh
    Hash sampleh = '( [zero]=0 [one]=1 )'
    assert equal '([one]="1" [zero]="0" )' "$(puts sampleh)"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "Assignment"; (
    _shpec_failures=0
    String sample = "an example"
    sample = "a new hope"
    assert equal "a new hope" "$(puts sample)"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "Calling Methods"; (
    _shpec_failures=0
    Array samples = '( zero one )'
    assert equal "zero-one" "$(puts samples .join -)"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "Method chaining"; (
    _shpec_failures=0
    Array samples = '( zero one )'
    assert equal ZERO-ONE "$(puts samples .join { - } .upcase)"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "Blocks"; (
    _shpec_failures=0
    declare -A sampleh
    Hash sampleh = '( [zero]=0 )'
    assert equal '([0]="zero: 0")' "$(puts sampleh .map [ {k,v} '$k: $v' ])"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "Object Literals"; (
    _shpec_failures=0
    assert equal "HELLO, WORLD!" "$(puts String "hello, world!" .upcase)"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "Class Creation"; (
    _shpec_failures=0
    class Fruit; {
      def tasty? <<'      end'
        puts "Heck yeah!"
      end

      def fresh? <<'      end'
        puts "You bet."
      end
    }

    Fruit .new myfruit
    assert equal "You bet." "$(myfruit .fresh?)"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "Inheritance 1"; (
    _shpec_failures=0
    class Fruit; {
      def tasty? <<'      end'
        puts "Heck yeah!"
      end

      def fresh? <<'      end'
        puts "You bet."
      end
    }

    class Banana : Fruit; {
      def fresh? <<'      end'
        puts "Not so much."
      end
    }

    Banana .new mybanana
    assert equal "Not so much." "$(mybanana .fresh?)"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "Inheritance 2"; (
    _shpec_failures=0
    class Fruit; {
      def tasty? <<'      end'
        puts "Heck yeah!"
      end

      def fresh? <<'      end'
        puts "You bet."
      end
    }

    class Banana : Fruit; {
      def fresh? <<'      end'
        puts "Not so much."
      end
    }

    Banana .new mybanana
    assert equal "Heck yeah!" "$(mybanana .tasty?)"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "Introspection 1"; (
    _shpec_failures=0
    assert equal '"Class"' "$(puts Array .class)"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "Introspection 2"; (
    _shpec_failures=0
    assert equal '"Object"' "$(puts Array .superclass)"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "Introspection 3"; (
    _shpec_failures=0
    assert equal '([0]="Array" [1]="Object")' "$(puts Array .ancestors)"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "Introspection 4"; (
    _shpec_failures=0
    assert equal '([0]="ancestors" [1]="declare" [2]="instance_methods" [3]="new" [4]="superclass" [5]="class" [6]="methods")' "$(puts Class .methods)"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end

  it "Introspection 5"; (
    _shpec_failures=0
    assert equal '([0]="ancestors" [1]="declare" [2]="instance_methods" [3]="new" [4]="superclass")' "$(puts Class .instance_methods false)"
    return "$_shpec_failures" ); (( _shpec_failures += $? )) ||:
  end
end
