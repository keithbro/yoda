package Yoda;
use 5.008001;
use strict;
use warnings;

use Exporter 'import';
use JSON::XS qw(encode_json);
use List::Util qw();
use Scalar::Util qw(blessed);
use Test::Deep::NoTest qw(cmp_details superhashof);
use Try::Tiny;

our $VERSION = "0.01";

our @EXPORT_OK = qw(
    __ add always any append apply chain complement compose concat cond
    contains converge divide equals F filter flatten flip group_by head
    identity if_else intersection is_defined juxt lt max memoize min multiply
    partition path pick pick_all product prop range reduce reduced reject
    replace subtract sum T take to_lower to_upper transduce try_catch unapply
    unfold values zip_with
);

=encoding utf-8

=head1 NAME

Yoda - Perl port of Ramda

=head1 SYNOPSIS

    use Yoda qw(compose memoize product range);

    my $factorial = memoize(compose(product(), range(1)));
    $factorial->(5); # 120

=head1 DESCRIPTION

Yoda is a practical functional library for Perl programmers.

=head1 ETYMOLOGY

In-keeping with the ovine theme, the name comes from a mispronunciation that I
heard in the West of Ireland of the word "ewe" as /jəʊ/ (yo), and the "da" from
Ramda and lambda at the end. Also, who wouldn't want to call their project
Yoda!?

Or functionally,

    my $pronunce_syllable = if_else(
        equals('ewe'), always('yo'), identity(),
    );

    my $pronunce_syllables = compose(
        Yoda::join(''),
        Yoda::map($pronunce_syllable),
    );

    $pronunce_syllables->(['ewe', 'da']); # yoda


=head1 FUNCTIONS

=head2 __

    * -> Yoda::__

Returns an argument placeholder.

    my $divide_by_10 = divide(__(), 10);
    $divide_by_10->(100); # 10

    my $greet = replace('{name}', __, 'Hello, {name}!');
    $greet->('Alice'); # 'Hello, Alice!'

=cut

sub __ {
    return bless( { }, 'Yoda::__' );
}

=head2 add

    Num → Num → Num

Adds two numbers.

    add(3, -10); # -7

=cut

sub add { _curry2( sub { $_[0] + $_[1] }, @_ ) }

=head2 always

    a → (* → a)

Returns a function that always returns the given value.

    my $t = always('Tee');
    $t->(); # 'Tee'

=cut

sub always { _curry1( sub { my ($c) = @_; return sub { $c } }, @_ ) }

=head2 any

    (a → Bool) → [a] → Bool

Returns 1 if at least one of the elements in the list match the predicate,
undef otherwise.

    my $less_than_0 = flip(lt())->(0);
    my $less_than_2 = flip(lt())->(2);

    any($less_than_0)->([1, 2]); # undef
    any($less_than_2)->([1, 2]); # 1

=cut

sub any { _curry2( sub { _any(@_) }, @_ ) }

=head2 append

    a → [a] → [a]

Returns a new list containing the contents of the given list, followed by the
given element.

    append('tests', ['write', 'more']);     # ['write', 'more', 'tests']
    append('tests', []);                    # ['tests']
    append(['tests'], ['write', 'more']);   # ['write', 'more', ['tests']]

=cut

sub append { _curry2( sub { [ @{$_[1]}, $_[0] ] }, @_ ) }

=head2 apply

    (*… → a) → [*] → a

Applies function fn to the argument list args. This is useful for creating a
fixed-arity function from a variadic function.

    my $numbers = [1, 2, 3, -99, 42, 6, 7];
    apply(\&List::Util::max, $numbers); # 42

=cut

sub apply { _curry2( sub { $_[0]->(@{$_[1]}) }, @_) }

=head2 chain

    Chain m => (a → m b) → m a → m b

chain maps a function over a list and concatenates the results. Note that
functions are chains and so by replacing `m` with `x → `, the signature is
also:

    (a → x → b) → (x → a) → x → b

Example:

    my $duplicate = sub { [ $_[0], $_[0] ] };

    chain($duplicate, [1, 2, 3]); # [1, 1, 2, 2, 3, 3]

    chain(append(), head())->([1, 2, 3]); # [1, 2, 3, 1]

=cut

sub chain {
    my @args = @_;

    if (ref($args[-1]) ne 'ARRAY') {
        return sub { chain( @args, @_ ) };
    }

    if (scalar @args == 2) {
        my ($f, $list) = @args;
        return [ map { @{$f->($_)} } @$list ];
    }

    if (scalar @args == 3) {
        my ($f, $g, $list) = @_;
        my $el = $g->($list);
        return $f->($el, $list);
    }
}

=head2 complement

    (*… → *) → (*… → Boolean)

Takes a function f and returns a function g such that if called with the same
arguments when f returns a "truthy" value, g returns false and when f returns a
"falsy" value g returns true.

    my $is_undefined = complement(is_defined());

    $is_undefined->(undef); # 1
    $is_undefined->(7); # ''

=cut

sub complement {
    _curry1(sub {
        my ($f) = @_;
        return sub { not $f->(@_) };
    }, @_);
}

=head2 compose

    ((y → z), (x → y), …, (o → p), ((a, b, …, n) → o)) → ((a, b, …, n) → z)

Performs right-to-left function composition. The rightmost function may have any
arity; the remaining functions must be unary.

Note: The result of compose is not automatically curried.

    my $abs = sub { abs(shift()) };

    my $classy_greeting = sub {
        sprintf("The name's %s, %s %s.", $_[1], $_[0], $_[1]);
    };

    my $yell_greeting = compose(to_upper, $classy_greeting);

    $yell_greeting->('James', 'Bond'); # "THE NAME'S BOND, JAMES BOND."

    compose($abs, add(1), multiply(2))->(-4); # 7

=cut

sub compose {
    my @funcs = @_;

    return sub {
        my @args = @_;
        @args = $_->(@args) for reverse @funcs;
        $args[0];
    };
}

=head2 concat

    [a] → [a] → [a]
    Str → Str → Str

Returns the result of concatenating the given lists or strings.

    concat('ABC', 'DEF'); # ABCDEF
    concat([4, 5, 6], [1, 2, 3]); # [4, 5, 6, 1, 2, 3]
    concat([], []); # []

=cut

sub concat {
    _curry2(sub {
        my ($x, $y) = @_;

        if (ref($x) eq 'ARRAY' && ref($y) eq 'ARRAY') {
            return [ @$x, @$y ];
        }

        $x.$y;
    }, @_);
}

=head2 cond

    [[(*… → Bool),(*… → *)]] → (*… → *)

Returns a function, fn, which encapsulates if/else, if/else, … logic. `cond`
takes a list of [predicate, transformer] pairs. All of the arguments to fn are
applied to each of the predicates in turn until one returns a "truthy" value, at
which point fn returns the result of applying its arguments to the corresponding
transformer. If none of the predicates matches, fn returns `undef`.

    my $fn = cond([
        [equals(0),   always('water freezes at 0°C')],
        [equals(100), always('water boils at 100°C')],
        [T(),         sub { 'nothing special happens at ' . shift() . '°C' }],
    ]);
    $fn->(0);   # 'water freezes at 0°C'
    $fn->(50);  # 'nothing special happens at 50°C'
    $fn->(100); # 'water boils at 100°C'

=cut

sub cond {
    _curry1(sub {
        my ($predicate_transformer_pairs) = @_;

        return sub {
            my ($value) = @_;

            for my $pair (@$predicate_transformer_pairs) {
                return $pair->[1]->($value) if $pair->[0]->($value);
            }

            return undef;
        };
    }, @_);
}

=head2 contains

    a → [a] → Bool

Returns 1 if the specified value is equal, in `equals` terms, to at least one
element of the given list; or the empty string otherwise.

    contains(3, [1, 2, 3]); # 1
    contains(4, [1, 2, 3]); # ''
    contains({ name: 'Fred' }, [{ name: 'Fred' }]); # 1
    contains([42], [[42]]); # 1
    contains('s', 'bars'); # 1

=cut

sub contains {
    _curry2(sub {
        my ($value, $list_or_string) = @_;

        my @list = ref($list_or_string)
            ? @$list_or_string
            : split(//, $list_or_string);
        my $value_as_string = _to_string($value);

        for my $element (@list) {
            return 1 if _to_string($element) eq $value_as_string;
        }

        return '';
    }, @_);
}

=head2 converge

    (x1 → x2 → … → z) → [(a → b → … → x1), (a → b → … → x2), …] → (a → b → … → z)

Accepts a converging function and a list of branching functions and returns a
new function. When invoked, this new function is applied to some arguments, each
branching function is applied to those same arguments. The results of each
branching function are passed as arguments to the converging function to produce
the return value.

    my $average = converge(divide(), [sum(), Yoda::length()]);
    $average->([1,2,3,4,5,6,7]); # 4

    my $strange_concat = converge(concat(), [to_upper(), to_lower()]);
    $strange_concat->("Yodel"); # YODELyodel

=cut

sub converge {
    _curry2(sub {
        my ($converging_function, $branching_functions) = @_;

        return sub {
            my @args = map { $_->(@_) } @$branching_functions;
            return $converging_function->(@args);
        };
    }, @_);
}

=head2 divide

    Num → Num → Num

Divides two numbers. Equivalent to a / b.

    divide(71, 100); # 0.71

    my $reciprocal = divide(1);
    $reciprocal->(4); # 0.25

=cut

sub divide { _curry2( sub { $_[0] / $_[1] }, @_ ) }

=head2 equals

    a → b → Bool

Returns 1 if its arguments are equivalent, the empty string otherwise. Currently
does not handles cyclical data structures, unlike Ramda.

    equals(1, 1); # 1
    equals(1, '1'); # ''
    equals([1, 2, 3], [1, 2, 3]); # 1

=cut

sub equals {
    _curry2(sub {
        my ($x, $y) = @_;
        return _to_string($x) eq _to_string($y);
    }, @_);
}

=head2 F

    * → Bool

A function that always returns the empty string. Any passed in parameters are
ignored.

    F(); # ''

=cut

sub F { sub { '' } }

=head2 filter

    Filterable f => (a → Bool) → f a → f a

Takes a predicate and a "filterable", and returns a new filterable of the same
type containing the members of the given filterable which satisfy the given
predicate.

    my $is_even = sub { shift() % 2 == 0 };

    filter($is_even, [1, 2, 3, 4]); # [2, 4]

    filter($is_even, {a => 1, b => 2, c => 3, d => 4}); # {b => 2, d => 4}

=cut

sub filter {
    _curry2(sub {
        my ($predicate, $filterable) = @_;

        return ref($filterable) eq 'HASH'
            ? _filter_hashref(@_)
            : _filter_arrayref(@_);
    }, @_);
}

=head2 flatten

    [a] → [b]

Returns a new ArrayRef by pulling every element out of it (and all its
sub-ArrayRefs) and
putting them in a new ArrayRef, depth-first.

    flatten([1, 2, [3, 4], 5, [6, [7, 8, [9, [10, 11], 12]]]]) # [1..12]

=cut

sub flatten { _curry1( sub { [ _flatten($_[0]) ] }, @_ ) }

=head2 flip

    (a → b → c → … → z) → (b → a → c → … → z)

Returns a new function much like the supplied one, except that the first two
arguments' order is reversed.

    my $merge_three = sub {
        my ($x, $y, $z) = @_;
        [ $x, $y, $z ];
    };

    $merge_three->(1, 2, 3); # [1, 2, 3]
    flip($merge_three)->(1, 2, 3); # [2, 1, 3]

=cut

sub flip {
    _curry1(sub {
        my $func = shift;

        return sub {
            _curry2(sub {
                my $arg1 = shift;
                my $arg2 = shift;
                $func->($arg2, $arg1, @_);
            }, @_);
        };
    }, @_);
}

=head2 group_by

    (a → Str) → [a] → {Str: [a]}

Splits a list into sub-lists stored in an object, based on the result of calling
a String-returning function on each element, and grouping the results according
to values returned.

    my $by_grade = group_by(
        sub {
            my ($student) = @_;
            my $score = $student->{score};
            return $score < 65 ? 'F' :
                   $score < 70 ? 'D' :
                   $score < 80 ? 'C' :
                   $score < 90 ? 'B' : 'A';
        }
    );

    my $students = [
        {name => 'Abby', score => 84},
        {name => 'Eddy', score => 58},
        # …
        {name => 'Jack', score => 69},
    ];

    $by_grade->($students);
    # {
    #     'B' => [{name => 'Abby', score => 84}],
    #     'D' => [{name => 'Jack', score => 69}],
    #     …
    #     'F' => [{name => 'Eddy', score => 58}],
    # },

=cut

sub group_by { _curry2( sub { reduce_by(append(), [], @_ ) }, @_) }

=head2 head

    [a] → a | undef
    Str → Str

Returns the first element of the given list or string.

    head(['fi', 'fo', 'fum']); # 'fi'
    head([]); # undef

    head('abc'); # 'a'
    head(''); # ''

=cut

sub head {
    _curry1(sub {
        my ($list_or_string) = @_;
        return ref($list_or_string)
            ? $list_or_string->[0]
            : substr($list_or_string, 0, 1);
    }, @_);
}

=head2 identity

    a → a

A function that does nothing but return the parameter supplied to it. Good as a
default or placeholder function.

    identity(1); # 1

    my $obj = {};
    identity($obj); # $obj;

=cut

sub identity { _curry1( sub { $_[0] }, @_ ) }

=head2 if_else

    (*… → Bool) → (*… → *) → (*… → *)

Creates a function that will process either the on_true or the on_false function
depending upon the result of the condition predicate.

    my $pronunce_syllable = if_else(
        equals('ewe'),
        always('yo'),
        identity(),
    );

    $pronunce_syllable->('ewe'); # yo
    $pronunce_syllable->('no'); # no

=cut

sub if_else {
    _curry3(sub {
        my ($condition, $on_true, $on_false) = @_;

        return sub { $condition->(@_) ? $on_true->(@_) : $on_false->(@_) };
    }, @_);
}

=head2 intersection

    [*] → [*] → [*]

Combines two lists into a set (i.e. no duplicates) composed of those elements
common to both lists.

    intersection([1,2,3,4], [7,6,5,4,3]); # [4, 3]

=cut

sub intersection {
    _curry2(sub {
        my ($x, $y) = @_;

        my ($lookup, $filter);
        if (scalar @$x < scalar @$y) {
            $lookup = _uniq($x);
            $filter = _uniq($y);
        } else {
            $lookup = _uniq($y);
            $filter = _uniq($x);
        }

        return [
            map { $filter->{$_} }
            grep { $lookup->{$_} }
            keys %$filter
        ];
    }, @_);
}

=head2 is_defined

    a -> Bool

Checks if the input value is defined.

    is_defined(undef); # ''
    is_defined(3);     # 1

=cut

sub is_defined { _curry1( sub { defined $_[0] }, @_ ) }

=head2 join

    Str → [a] → Str

Returns a string made by inserting the separator between each element and
concatenating all the elements into a single string.

    my $spacer = join(' ');
    $spacer->(['a', 2, 3.4]); # 'a 2 3.4'
    join('|', [1, 2, 3]); # '1|2|3'

=cut

sub join { _curry2( sub { join( $_[0], @{$_[1]} ) }, @_ ) }

=head2 juxt

    [(a, b, …, m) → n] → ((a, b, …, m) → [n])

juxt applies a list of functions to a list of values.

    my $get_range = juxt([min(), max()]);
    $get_range->(3, 4, 9, -3); # [-3, 9]

=cut

sub juxt {
    _curry2(sub {
        my ($functions, @values) = @_;
        return [ map { $_->(@values) } @$functions ];
    }, @_);
}

=head2 length

    [a] → Num

Returns the number of elements in the array.

    length([]); # 0
    length([1, 2, 3]); # 3

=cut

sub length { _curry1( sub { scalar @{$_[0]} }, @_) }

=head2 lt

    a → a → Bool

Returns 1 if the first argument is less (according to the ASCII table) than the
second argument, undef otherwise.

    lt(2, 1);       # undef
    lt(2, 2);       # undef
    lt(2, 3);       # 1
    lt('a', 'z');   # 1
    !lt('z', 'a');  # undef
    lt(5, '^');     # 1

=cut

sub lt { _curry2( sub { ord($_[0]) < ord($_[1]) }, @_ ) }

=head2 map

    Functor f => (a → b) → f a → f b

Takes a function and a functor, applies the function to each of the functor's
values, and returns a functor of the same shape.

Yoda provides suitable map implementations for ArrayRef and HashRef, so this
function may be applied to [1, 2, 3] or {x => 1, y => 2, z => 3}.

    my $double = sub { shift() * 2 };

    Yoda::map($double, [1, 2, 3]) # [2, 4, 6]

    Yoda::map($double, {x => 1, y => 2, z => 3}) # {x => 2, y => 4, z => 6}

=cut

sub map {
    _curry2(sub {
        my ($function, $functor) = @_;
        return ref($functor) eq 'HASH' ? _map_hashref(@_) : _map_arrayref(@_);
    }, @_);
}

=head2 max

    [Num] → Num

Returns the larger of its two arguments.

    R.max(789, 123); # 789

=cut

sub max { _curry2( sub { List::Util::max(@_) }, @_ ) }

=head2 memoize

    (*… → a) → (*… → a)

Creates a new function that, when invoked, caches the result of calling fn for a
given argument set and returns the result. Subsequent calls to the memoized fn
with the same argument set will not result in an additional call to fn; instead,
the cached result for that set of arguments will be returned.

    my $count = 0;

    my $factorial = memoize(sub {
        my ($n) = @_;
        $count++;
        return product(range(1, $n));
    });

    $factorial->(5); # 120
    $factorial->(5); # 120
    $count; # 1

=cut

sub memoize {
    _curry1(sub {
        my ($func) = @_;

        my %memo;
        return sub {
            my $key = encode_json(\@_);

            return $memo{$key} if exists $memo{$key};
            return $memo{$key} = $func->(@_);
        };
    }, @_);
}

=head2 min

    [Num] → Num

Returns the smaller of its two arguments.

    R.min(789, 123); # 123

=cut

sub min { _curry2( sub { List::Util::min(@_) }, @_ ) }

=head2 multiply

    Num → Num → Num

Multiples two numbers.

    multiply(3, -7); # -21

=cut

sub multiply { _curry2( sub { $_[0] * $_[1] }, @_ ) }

=head2 partition

    Filterable f => (a → Bool) → f a → [f a, f a]

Takes a predicate and a list or other "filterable" object and returns the pair
of filterable objects of the same type of elements which do and do not satisfy,
the predicate, respectively.

    partition(contains('s'), ['sss', 'ttt', 'foo', 'bars']);
    # [ [ 'sss', 'bars' ],  [ 'ttt', 'foo' ] ]

    partition(contains('s'), { a => 'sss', b => 'ttt', foo => 'bars' });
    # [ { a => 'sss', foo => 'bars' }, { b => 'ttt' } ]

=cut

sub partition {
    _curry2(sub {
        my ($predicate, $filterable) = @_;
        return juxt( [ filter(), reject() ], $predicate, $filterable );
    }, @_);
}

=head2 path

    [Idx] → {a} → a | Undefined
    Idx = String | Int

Retrieve the value at a given path.

    path(['a', 'b'], {a => {b => 2}}); # 2
    path(['a', 'b'], {c => {b => 2}}); # undef

=cut

sub path {
    _curry2( sub { reduce( sub { $_[0]->{$_[1]} }, $_[1], $_[0] ) }, @_);
}

=head2 pick

    [Str] -> {Str: *} -> {Str: *}
    [PositiveInt] -> [a] -> {PositiveInt: a}

Returns a partial copy of an HashRef containing only the keys specified. If the
key does not exist, the property is ignored.

Also allows the picking of elements from an ArrayRef by index.

    my $hash_ref = { a => 1, b => 2, c => 3, d => 4, e => 0 };
    my $array_ref = [ sort keys %$hash_ref ];

    pick(['a', 'd'], $hash_ref); # { a => 1, d => 4 }

    pick(['a', 'e', 'f'], $hash_ref); # { a => 1, e => 0 }

    pick_all([0, 2], $array_ref); # { 0 => 'a', 2 => 'c' }

=cut

sub pick {
    _curry2( sub { filter(is_defined(), pick_all(@_)) }, @_ );
}

=head2 pick_all

    [Str] -> {Str: *} -> {Str: *}
    [PositiveInt] -> [a] -> {PositiveInt: a}

Similar to pick except that this one includes a key: undef pair for keys
that don't exist.

    my $hash_ref = { a => 1, b => 2, c => 3, d => 4, e => 0 };
    my $array_ref = [ sort keys %$hash_ref ];

    pick_all(['a', 'd'], $hash_ref); # { a => 1, d => 4 }

    pick_all(['a', 'e', 'f'], $hash_ref); # { a => 1, e => 0, f => undef }

    pick_all([0, 2], $array_ref); # { 0 => 'a', 2 => 'c' }

=cut

sub pick_all {
    _curry2(sub {
        my ($keys, $ref) = @_;

        if (ref($ref) eq 'ARRAY') {
            return { map { $_ => $ref->[$_] } @$keys };
        }

        if (ref($ref) eq 'HASH') {
            return { map { $_ => $ref->{$_} } @$keys };
        }

        die 'second argument must be an ArrayRef or HashRef';
    }, @_);
}

=head2 product

    [Num] → Num

=cut

sub product { _curry1( sub { reduce( multiply(), 1, $_[0] ) }, @_) }

=head2 prop

    Stringable s => s → HashRef[a]|Blessed → Maybe[a]

Given a $key and either a HashRef or a blessed $object, returns the attribute
value for that $key. Equivalent to:

    $hashref->{$key} or $blessed_object->$key()

    prop('x', {x => 100}); # 100
    prop('x', {}); # undef
    prop('x', undef); # throws exception

=cut

sub prop {
    _curry2(sub {
        my ($key, $object) = @_;

        return $object->{$key} if ref($object) eq 'HASH';
        return $object->$key() if blessed($object);

        die 'second argument must be a HashRef or blessed';
    }, @_)
}

=head2 range

    Num → Num → [Num]

=cut

sub range { _curry2( sub { [ $_[0]..$_[1] ] }, @_ ) }

=head2 reduce

    (a → b → a) → a → [b] → a

Returns a single item by iterating through the list, successively calling the
iterator function and passing it an accumulator value and the current value from
the array, and then passing the result to the next call.

The iterator function receives two values: (acc, value).

    reduce(subtract, 0, [1, 2, 3, 4]) # ((((0 - 1) - 2) - 3) - 4) = -10

=cut

sub reduce {
    _curry3(sub {
        my ($iterator, $initial_value, $list) = @_;

        my $value = $initial_value;
        for my $element (@$list) {
            my $next_value = $iterator->($value, $element);

            if (ref($next_value) eq 'Yoda::Reduced') {
                $value = $next_value->{value};
                last;
            }

            $value = $next_value;
        }
        return $value;
    }, @_);
}

=head2 reduced

    * -> Yoda::Reduced

Returns a value wrapped to indicate that it is the final value of the reduce
and transduce functions.

    my $reducer = sub {
        my $sum = sum(\@_);
        return $sum >= 10 ? reduced($sum) : $sum;
    };

    reduce($reducer, 0, [ 1..5 ]); # 10

=cut

sub reduced { bless( { value => $_[0] }, 'Yoda::Reduced' ) }

=head2 reduce_by

    ((a, b) → a) → a → (b → Str) → [b] → {Str: a}

=cut

sub reduce_by {
    _curry_n(4, sub {
        my ($value_func, $initial_value, $key_func, $elements) = @_;

        my %h;

        for my $element (@$elements) {
            my $key = $key_func->($element);
            my $value = $h{$key} // $initial_value;
            $h{$key} = $value_func->($element, $value);
        }

        return \%h;
    }, @_);
}

=head2 reject

    Filterable f => (a → Bool) → f a → f a

The complement of filter.

    my $is_odd = sub { $_[0] % 2 == 1 };

    reject($is_odd, [1, 2, 3, 4]); # [2, 4]

    reject($is_odd, {a => 1, b => 2, c => 3, d => 4});
    # {b => 2, d => 4}

=cut

sub reject {
    _curry2(sub {
        my ($predicate, $filterable) = @_;

        if (ref($filterable) eq 'ARRAY') {
            return [ grep { ! $predicate->($_) } @$filterable ];
        }

        return {
            map { $_ => $filterable->{$_} }
            grep { ! $predicate->($filterable->{$_}) }
            keys %$filterable
        };
    }, @_);
}

=head2 replace

    RegexpRef|Str -> Str|[Str] -> Str -> Str

    (a -> Bool) -> a|[a] -> [a] -> [a]

Given a $predicate, one or more $replacements, and an $original, replace
matches in the original with the replacements.

The $predicate can be a regular expression, a single value or a function.

If $replacements is an ArrayRef, replacements will cease once all replacements
have been used. Alternatively if $replacements is a single value, it will
replace all matches.

    replace('foo'  , 'bar'                  , 'foo foo foo'); # 'bar bar bar'
    replace(qr/foo/, 'bar'                  , 'foo foo foo'); # 'bar bar bar'
    replace(qr/foo/, [ 'bar' ]              , 'foo foo foo'); # 'bar foo foo'
    replace('foo'  , [ 'bar', 'baz', 'bad' ], 'foo foo foo'); # 'bar baz bad'

    my $original = [3, 7, 'x', 5, 'x', 'x', 9];
    my $replacements = [0, 2];
    my $predicate = equals('x');

    replace($predicate, $replacements, $original); # [ 3, 7, 0, 5, 2, 'x', 9]

    replace($predicate, 'y', $original); # [ 3, 7, 'y', 5, 'y', 'y', 9 ]

=cut

sub replace {
    _curry3(sub {
        my ($predicate, $replacements, $original) = @_;

        return _replace_using_coderef(@_) if ref $predicate eq 'CODE';

        my $regex = ref $predicate eq 'REGEXP' ? $predicate : qr/$predicate/;

        if (ref $replacements) {
            $original =~ s/$regex/$_/ for @$replacements;
        } else {
            $original =~ s/$regex/$replacements/g;
        }

        return $original;
    }, @_);
}

=head2 subtract

    Num → Num → Num

=cut

sub subtract { _curry2( sub { $_[0] - $_[1] }, @_ ) }

=head2 sum

    [Num] → Num

Adds together all the elements of a list.

    sum([2,4,6,8,100,1]); # 121

=cut

sub sum { _curry1( sub { reduce( add(), 0, @_ ) }, @_ ) }

=head2 T

    * → Bool

A function that always returns 1. Any passed in parameters are ignored.

    T(); # 1

=cut

sub T { sub { 1 } }

=head2 take

    Num -> [a] -> [a]
    Num -> Str -> Str

Returns the first n elements of the given list or string.

    take(1, ['foo', 'bar', 'baz']); # ['foo']
    take(2, ['foo', 'bar', 'baz']); # ['foo', 'bar']
    take(3, ['foo', 'bar', 'baz']); # ['foo', 'bar', 'baz']
    take(4, ['foo', 'bar', 'baz']); # ['foo', 'bar', 'baz']
    take(3, ['foo', undef, 'baz']); # ['foo', undef, 'baz']
    take(3, 'ramda');               # 'ram'

    my $personnel = [
        'Dave Brubeck',
        'Paul Desmond',
        'Eugene Wright',
        'Joe Morello',
        'Gerry Mulligan',
        'Bob Bates',
        'Joe Dodge',
        'Ron Crotty'
    ];

    my $take_five = take(5);
    $take_five->($personnel);
    # ['Dave Brubeck', 'Paul Desmond', 'Eugene Wright', 'Joe Morello', 'Gerry Mulligan']

=cut

sub take {
    _curry2(sub {
        my ($n) = @_;

        my $ref_type = ref($_[1]);
        my $list              = $ref_type eq 'ARRAY' ? $_[1] : undef;
        my $string            = !$ref_type           ? $_[1] : undef;
        my $reducing_function = $ref_type eq 'CODE'  ? $_[1] : flip(append());

        my $predicate = sub {
            my ($prev) = @_;
            my $size = scalar(@$prev);
            return ($size < $n) ? 1 : ($size == $n) ? 0 : die();
        };

        my $reducer = _build_take_reducer($predicate)->($reducing_function);
        return $reducer if $ref_type eq 'CODE';

        my @elements = $string ? split(//, $string) : @$list;
        my $taken = reduce($reducer, [], \@elements);

        return $string ? CORE::join('', @$taken) : $taken;
    }, @_);
}

=head2 to_lower

    Str → Str

Returns the lower case version of a string.

    to_lower('ABC'); # abc

=cut

sub to_lower { _curry1( sub { lc($_[0]) }, @_ ) }

=head2 to_upper

    Str → Str

Returns the upper case version of a string.

    to_upper('abc'); # 'ABC'

=cut

sub to_upper { _curry1( sub { uc( $_[0] ) }, @_ ) }

=head2 transduce

    (c → c) → (a,b → a) → a → [b] → a

Initializes a transducer using supplied iterator function. Returns a single
item by iterating through the list, successively calling the transformed
iterator function and passing it an accumulator value and the current value
from the array, and then passing the result to the next call.

    my $numbers = [ 1..10 ];

    my $transducer = compose(
        Yoda::map(add(1)), # [ 2..11 ]
        filter($is_even),  # [ 2, 4, 6, 8, 10 ]
        take(3),           # [ 2, 4, 6 ]
    );

    transduce($transducer, flip(append()), [], $numbers); # [ 2, 4, 6 ]

=cut

sub transduce {
    _curry4(sub {
        my ($transducer, $reducing_function, $initial_value, $list) = @_;
        reduce($transducer->($reducing_function), $initial_value, $list);
    }, @_);
}

=head2 transpose

    [[a]] → [[a]]

=cut

sub transpose {
    _curry1(sub {
        my ($arrayrefs) = @_;

        my $index = 0;
        my @transposed_arrayrefs;
        while (1) {
            my @transposed_arrayref =
                grep { defined } map { $_->[$index] } @$arrayrefs;

            scalar @transposed_arrayref or return \@transposed_arrayrefs;

            push @transposed_arrayrefs, \@transposed_arrayref;
            $index++;
        }
    }, @_);
}

=head2 try_catch

    (…x → a) → ((e, …x) → a) → (…x → a)

try_catch takes two functions, a tryer and a catcher. The returned function
evaluates the tryer; if it does not throw, it simply returns the result. If the
tryer does throw, the returned function evaluates the catcher function and
returns its result. Note that for effective composition with this function, both
the tryer and catcher functions must return the same type of results.

    try_catch(prop('x'), F())({x => 1}); # 1
    try_catch(prop('x'), F())(undef); # ''

=cut

sub try_catch {
    _curry2(sub {
        my ($tryer, $catcher) = @_;

        return sub {
            my @args = @_;
            try {
                $tryer->(@args);
            } catch {
                $catcher->($_);
            };
        };
    }, @_);
}

=head2 unapply

    ([*…] → a) → (*… → a)

Takes a function fn, which takes a single array argument, and returns a
function which:

* takes any number of positional arguments;
* passes these arguments to fn as an array; and
* returns the result.

In other words, unapply derives a variadic function from a function which
takes an array. unapply is the inverse of apply.

    my $join_with_space = Yoda::join(' ');

    unapply($join_with_space)->('hello', 'world'); # 'hello world'

=cut

sub unapply {
    _curry1(sub {
        my ($func) = @_;
        return sub { $func->(\@_) };
    }, @_);
}

=head2 unfold

    (a → [b]) → * → [b]

Builds a list from a seed value. Accepts an iterator function, which returns
either a falsey value to stop iteration or an array of length 2 containing the
value to add to the resulting list and the seed to be used in the next call to
the iterator function.

The iterator function receives one argument: (seed).

    my $f = sub { my ($n) = @_; $n > 50 ? '' : [-$n, $n + 10] };

    unfold($f, 10); # [-10, -20, -30, -40, -50];


=cut

sub unfold {
    _curry2(sub {
        my ($func, $seed) = @_;

        my $pair = $func->($seed);
        my @result;

        while ($pair && scalar @$pair) {
            push @result, $pair->[0];
            $pair = $func->($pair->[1]);
        }

        return \@result;
    }, @_);
}

=head2 uniq

    [a] → [a]

=cut

sub uniq {
    _curry1(sub {
        my ($elements) = @_;
        my $element_for_string = _uniq($elements);
        return [ values %$element_for_string ];
    }, @_);
}

=head2 union

    [*] → [*] → [*]

=cut

sub union { _curry2( sub { uniq( [ map { @$_ } @_ ] ) }, @_ ) }

=head2 values

    {Str: *} → [*]

Returns an ArrayRef of values from the supplied HashRef. The values are sorted
by their keys.

    values({ a => 1, b => 3, c => 2 }); # [1, 3, 2]

=cut

sub values {
    _curry1( sub { [ map { $_[0]->{$_} } sort keys %{$_[0]} ] }, @_ );
}

=head2 where_eq

    {Str: *} → {Str: *} → Bool

=cut

sub where_eq {
    _curry2(sub {
        my ($spec, $test) = @_;
        my ($ok) = cmp_details($test, superhashof($spec));
        return $ok;
    }, @_);
}

=head2 zip_with

    (a → b → c) → [a] → [b] → [c]

Creates a new list out of the two supplied by applying the function to each
equally-positioned pair in the lists. The returned list is truncated to the
length of the shorter of the two input lists.

    my $f = sub { my ($x, $y) = @_; … };

    zipWith($f, [1, 2, 3], ['a', 'b', 'c']);
    # [f->(1, 'a'), f->(2, 'b'), f->(3, 'c')]

=cut

sub zip_with {
    _curry3(sub {
        my ($func, $x, $y) = @_;

        my $min = min(scalar @$x, scalar @$y) - 1;

        return [ map { $func->($x->[$_], $y->[$_]) } 0 .. $min ];
    }, @_);
}

sub _any {
    my ($predicate, $arrayref) = @_;
    for my $element (@$arrayref) {
        return 1 if $predicate->($element);
    }
    return undef;
}

sub _build_filter_reducer {
    my ($predicate) = @_;

    return sub {
        my ($reducing_function) = @_;

        return sub {
            my ($prev, $next) = @_;
            return $predicate->($next)
                ? $reducing_function->($prev, $next)
                : $prev;
        };
    };
}

sub _build_map_reducer {
    my ($mapping_function) = @_;

    return sub {
        my ($reducing_function) = @_;

        return sub {
            my ($prev, $next) = @_;
            return $reducing_function->($prev, $mapping_function->($next));
        };
    };
}

sub _build_take_reducer {
    my ($predicate) = @_;

    return sub {
        my ($reducing_function) = @_;

        return sub {
            my $reduced = $reducing_function->(@_);
            return $predicate->($reduced) ? $reduced : reduced($reduced);
        };
    };
}

sub _curry1 { _curry_n(1, @_) }
sub _curry2 { _curry_n(2, @_) }
sub _curry3 { _curry_n(3, @_) }
sub _curry4 { _curry_n(4, @_) }

sub _curry_n {
    my ($arity, $func, @args) = @_;

    if (_any(\&_is_placeholder, \@args)) {
        return sub {
            my $new_args = _replace_using_coderef(
                \&_is_placeholder, \@_, \@args,
            );
            $func->(@$new_args);
        }
    }

    if (scalar @args >= $arity) {
        return $func->(@args);
    }

    return sub { $func->(@args, @_) };
}

sub _filter_arrayref {
    my ($predicate, $arrayref_or_reducing_function) = @_;

    my $ref = ref($arrayref_or_reducing_function);
    my $reducing_function =
        $ref eq 'CODE' ? $arrayref_or_reducing_function : flip(append());

    my $reducer = _build_filter_reducer($predicate)->($reducing_function);
    return $reducer if $ref eq 'CODE';

    my $arrayref = $arrayref_or_reducing_function;
    reduce($reducer, [], $arrayref);
}

sub _filter_hashref {
    my ($predicate, $filterable) = @_;

    return {
        map { $_ => $filterable->{$_} }
        grep { $predicate->($filterable->{$_}) }
        keys %$filterable
    };
}

# _flatten
#
#   [*] → *…
#
# Given an ArrayRef, return a list completely flattened.

sub _flatten { map { ref $_ ? _flatten($_) : $_ } @{$_[0]} }

sub _is_placeholder { ref $_[0] eq 'Yoda::__' }

sub _map_arrayref {
    my ($function, $arrayref_or_reducing_function) = @_;

    my $ref = ref($arrayref_or_reducing_function);
    my $reducing_function =
        $ref eq 'CODE' ? $arrayref_or_reducing_function : flip(append());

    my $reducer = _build_map_reducer($function)->($reducing_function);
    return $reducer if $ref eq 'CODE';

    my $arrayref = $arrayref_or_reducing_function;
    reduce($reducer, [], $arrayref);
}

sub _map_hashref {
    my ($function, $hashref) = @_;
    return { map { $_ => $function->($hashref->{$_}) } keys %$hashref };
}

sub _replace_using_coderef {
    my ($predicate, $replacements, $array) = @_;

    my @array_with_replacements = @$array;
    my @replacements_left = ref $replacements
        ? @$replacements : ($replacements);

    for my $element (@array_with_replacements) {
        last unless @replacements_left;
        next unless $predicate->($element);

        $element = ref $replacements ? shift @replacements_left : $replacements;
    }

    return \@array_with_replacements;
}

sub _to_string {
    my ($value) = @_;
    return ref($value) ? encode_json($value) : encode_json({ a => $value });
}

# _uniq
#
#    [a] → {Str: a}
#
# Given a list, returns a HashRef where the keys are a unique Str representation
# of each element and the values are the (unique) elements.

sub _uniq {
    _curry1(sub {
        my ($elements) = @_;
        return { map { _to_string($_) => $_ } @$elements };
    }, @_);
}

1;

=head1 LICENSE

Copyright (C) Keith Broughton.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Keith Broughton C<< <keithbro [AT] cpan.org> >>

=cut

