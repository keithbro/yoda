[![Build Status](https://travis-ci.org/keithbro/yoda.svg?branch=master)](https://travis-ci.org/keithbro/yoda)
# NAME

Yoda - Perl port of Ramda

# SYNOPSIS

    use Yoda qw(compose memoize product range);

    my $factorial = memoize(compose(product(), range(1)));
    $factorial->(5); # 120

# DESCRIPTION

Yoda is a practical functional library for Perl programmers.

# ETYMOLOGY

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

# FUNCTIONS

## \_\_

    * -> Yoda::__

Returns an argument placeholder.

    my $divide_by_10 = divide(__(), 10);
    $divide_by_10->(100); # 10

    my $greet = replace('{name}', __, 'Hello, {name}!');
    $greet->('Alice'); # 'Hello, Alice!'

## add

    Num → Num → Num

Adds two numbers.

    add(3, -10); # -7

## always

    a → (* → a)

Returns a function that always returns the given value.

    my $t = always('Tee');
    $t->(); # 'Tee'

## any

    (a → Bool) → [a] → Bool

Returns 1 if at least one of the elements in the list match the predicate,
undef otherwise.

    my $less_than_0 = flip(lt())->(0);
    my $less_than_2 = flip(lt())->(2);

    any($less_than_0)->([1, 2]); # undef
    any($less_than_2)->([1, 2]); # 1

## append

    a → [a] → [a]

Returns a new list containing the contents of the given list, followed by the
given element.

    append('tests', ['write', 'more']);     # ['write', 'more', 'tests']
    append('tests', []);                    # ['tests']
    append(['tests'], ['write', 'more']);   # ['write', 'more', ['tests']]

## apply

    (*… → a) → [*] → a

Applies function fn to the argument list args. This is useful for creating a
fixed-arity function from a variadic function.

    my $numbers = [1, 2, 3, -99, 42, 6, 7];
    apply(\&List::Util::max, $numbers); # 42

## chain

    Chain m => (a → m b) → m a → m b

chain maps a function over a list and concatenates the results. Note that
functions are chains and so by replacing \`m\` with \`x → \`, the signature is
also:

    (a → x → b) → (x → a) → x → b

Example:

    my $duplicate = sub { [ $_[0], $_[0] ] };

    chain($duplicate, [1, 2, 3]); # [1, 1, 2, 2, 3, 3]

    chain(append(), head())->([1, 2, 3]); # [1, 2, 3, 1]

## complement

    (*… → *) → (*… → Boolean)

Takes a function f and returns a function g such that if called with the same
arguments when f returns a "truthy" value, g returns false and when f returns a
"falsy" value g returns true.

    my $is_undefined = complement(is_defined());

    $is_undefined->(undef); # 1
    $is_undefined->(7); # ''

## compose

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

## concat

    [a] → [a] → [a]
    Str → Str → Str

Returns the result of concatenating the given lists or strings.

    concat('ABC', 'DEF'); # ABCDEF
    concat([4, 5, 6], [1, 2, 3]); # [4, 5, 6, 1, 2, 3]
    concat([], []); # []

## cond

    [[(*… → Bool),(*… → *)]] → (*… → *)

Returns a function, fn, which encapsulates if/else, if/else, … logic. \`cond\`
takes a list of \[predicate, transformer\] pairs. All of the arguments to fn are
applied to each of the predicates in turn until one returns a "truthy" value, at
which point fn returns the result of applying its arguments to the corresponding
transformer. If none of the predicates matches, fn returns \`undef\`.

    my $fn = cond([
        [equals(0),   always('water freezes at 0°C')],
        [equals(100), always('water boils at 100°C')],
        [T(),         sub { 'nothing special happens at ' . shift() . '°C' }],
    ]);
    $fn->(0);   # 'water freezes at 0°C'
    $fn->(50);  # 'nothing special happens at 50°C'
    $fn->(100); # 'water boils at 100°C'

## contains

    a → [a] → Bool

Returns 1 if the specified value is equal, in \`equals\` terms, to at least one
element of the given list; or the empty string otherwise.

    contains(3, [1, 2, 3]); # 1
    contains(4, [1, 2, 3]); # undef
    contains('3', [1, 2, 3]); # undef
    contains({ name: 'Fred' }, [{ name: 'Fred' }]); # 1
    contains([42], [[42]]); # 1
    contains('s', 'bars'); # 1

## converge

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

## curry\_n

    Number → (* → a) → (* → a)

Returns a curried equivalent of the provided function, with the specified
arity.

The special placeholder function \_\_ may be used to specify "gaps", allowing
partial application of any combination of arguments, regardless of their
positions.

    my $sum_args = sub { sum(\@_) };

    my $curried_add_four_numbers = curry_n(4, $sum_args);
    my $f = $curried_add_four_numbers->(1, 2); # CodeRef
    my $g = $f->(3); # CodeRef

    $g->(4); # 10

## divide

    Num → Num → Num

Divides two numbers. Equivalent to a / b.

    divide(71, 100); # 0.71

    my $reciprocal = divide(1);
    $reciprocal->(4); # 0.25

## equals

    a → b → Bool

Returns 1 if its arguments are equivalent, the empty string otherwise. Currently
does not handles cyclical data structures, unlike Ramda.

    equals(1, 1); # 1
    equals(1, '1'); # ''
    equals([1, 2, 3], [1, 2, 3]); # 1

## F

    * → Bool

A function that always returns the empty string. Any passed in parameters are
ignored.

    F(); # ''

## filter

    Filterable f => (a → Bool) → f a → f a

Takes a predicate and a "filterable", and returns a new filterable of the same
type containing the members of the given filterable which satisfy the given
predicate.

    my $is_even = sub { shift() % 2 == 0 };

    filter($is_even, [1, 2, 3, 4]); # [2, 4]

    filter($is_even, {a => 1, b => 2, c => 3, d => 4}); # {b => 2, d => 4}

## find

    (a → Bool) → [a] → a | undef

Returns the first element of the list which matches the predicate, or undef if
no element matches.

    my $xs = [{a => 1}, {a => 2}, {a => 3}];

    find(prop_eq('a', 2))->($xs); # {a => 2}

    find(prop_eq('a', 4))->($xs); # undef

## flatten

    [a] → [b]

Returns a new ArrayRef by pulling every element out of it (and all its
sub-ArrayRefs) and
putting them in a new ArrayRef, depth-first.

    flatten([1, 2, [3, 4], 5, [6, [7, 8, [9, [10, 11], 12]]]]) # [1..12]

## flip

    (a → b → c → … → z) → (b → a → c → … → z)

Returns a new function much like the supplied one, except that the first two
arguments' order is reversed.

    my $merge_three = sub {
        my ($x, $y, $z) = @_;
        [ $x, $y, $z ];
    };

    $merge_three->(1, 2, 3); # [1, 2, 3]
    flip($merge_three)->(1, 2, 3); # [2, 1, 3]

## group\_by

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

## head

    [a] → a | undef
    Str → Str

Returns the first element of the given list or string.

    head(['fi', 'fo', 'fum']); # 'fi'
    head([]); # undef

    head('abc'); # 'a'
    head(''); # ''

## identity

    a → a

A function that does nothing but return the parameter supplied to it. Good as a
default or placeholder function.

    identity(1); # 1

    my $obj = {};
    identity($obj); # $obj;

## if\_else

    (*… → Bool) → (*… → *) → (*… → *)

Creates a function that will process either the on\_true or the on\_false function
depending upon the result of the condition predicate.

    my $pronunce_syllable = if_else(
        equals('ewe'),
        always('yo'),
        identity(),
    );

    $pronunce_syllable->('ewe'); # yo
    $pronunce_syllable->('no'); # no

## inc

    Num → Num

Increments its argument.

    inc(5); # 6

## intersection

    [*] → [*] → [*]

Combines two lists into a set (i.e. no duplicates) composed of those elements
common to both lists.

    intersection([1,2,3,4], [7,6,5,4,3]); # [4, 3]

## is\_defined

    a -> Bool

Checks if the input value is defined.

    is_defined(undef); # ''
    is_defined(3);     # 1

## is\_empty

    * -> Bool

Returns 1 if the given value is its type's empty value; undef otherwise.

    is_empty([]); # 1
    is_empty({}); # 1
    is_empty(''); # 1

    is_empty([1, 2, 3]); # undef
    is_empty({length => 0}); # undef
    is_empty('hello'); # undef

    is_empty(0); # undef
    is_empty(undef); # undef
    is_empty(bless({}, 'Animal')); # undef

## join

    Str → [a] → Str

Returns a string made by inserting the separator between each element and
concatenating all the elements into a single string.

    my $spacer = join(' ');
    $spacer->(['a', 2, 3.4]); # 'a 2 3.4'
    join('|', [1, 2, 3]); # '1|2|3'

## juxt

    [(a, b, …, m) → n] → ((a, b, …, m) → [n])

juxt applies a list of functions to a list of values.

    my $get_range = juxt([min(), max()]);
    $get_range->(3, 4, 9, -3); # [-3, 9]

## length

    [a] → Num

Returns the number of elements in the array.

    length([]); # 0
    length([1, 2, 3]); # 3

## lt

    a → a → Bool

Returns 1 if the first argument is less (according to the ASCII table) than the
second argument, undef otherwise.

    lt(2, 1);       # undef
    lt(2, 2);       # undef
    lt(2, 3);       # 1
    lt('a', 'z');   # 1
    !lt('z', 'a');  # undef
    lt(5, '^');     # 1

## map

    Functor f => (a → b) → f a → f b

Takes a function and a functor, applies the function to each of the functor's
values, and returns a functor of the same shape.

Yoda provides suitable map implementations for ArrayRef and HashRef, so this
function may be applied to \[1, 2, 3\] or {x => 1, y => 2, z => 3}.

    my $double = sub { shift() * 2 };

    Yoda::map($double, [1, 2, 3]) # [2, 4, 6]

    Yoda::map($double, {x => 1, y => 2, z => 3}) # {x => 2, y => 4, z => 6}

## max

    [Num] → Num

Returns the larger of its two arguments.

    R.max(789, 123); # 789

## memoize

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

## min

    [Num] → Num

Returns the smaller of its two arguments.

    R.min(789, 123); # 123

## multiply

    Num → Num → Num

Multiples two numbers.

    multiply(3, -7); # -21

## negate

    Num -> Num

Negates its argument.

    negate(-7); # 7

## partition

    Filterable f => (a → Bool) → f a → [f a, f a]

Takes a predicate and a list or other "filterable" object and returns the pair
of filterable objects of the same type of elements which do and do not satisfy,
the predicate, respectively.

    partition(contains('s'), ['sss', 'ttt', 'foo', 'bars']);
    # [ [ 'sss', 'bars' ],  [ 'ttt', 'foo' ] ]

    partition(contains('s'), { a => 'sss', b => 'ttt', foo => 'bars' });
    # [ { a => 'sss', foo => 'bars' }, { b => 'ttt' } ]

## path

    [Idx] → {a} → a | Undefined
    Idx = String | Int

Retrieve the value at a given path.

    path(['a', 'b'], {a => {b => 2}}); # 2
    path(['a', 'b'], {c => {b => 2}}); # undef

## pick

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

## pick\_all

    [Str] -> {Str: *} -> {Str: *}
    [PositiveInt] -> [a] -> {PositiveInt: a}

Similar to pick except that this one includes a key: undef pair for keys
that don't exist.

    my $hash_ref = { a => 1, b => 2, c => 3, d => 4, e => 0 };
    my $array_ref = [ sort keys %$hash_ref ];

    pick_all(['a', 'd'], $hash_ref); # { a => 1, d => 4 }

    pick_all(['a', 'e', 'f'], $hash_ref); # { a => 1, e => 0, f => undef }

    pick_all([0, 2], $array_ref); # { 0 => 'a', 2 => 'c' }

## pipe

    (((a, b, …, n) → o), (o → p), …, (x → y), (y → z)) → ((a, b, …, n) → z)

Performs left-to-right function composition. The leftmost function may have any
arity; the remaining functions must be unary.

Note: The result of pipe is not automatically curried.

    my $pow = curry_n(2, sub { $_[0] ** $_[1] });

    my $f = pipe($pow, negate(), inc());

    $f->(3, 4); # -(3^4) + 1

## product

    [Num] → Num

## prop

    Stringable s => s → HashRef[a]|Blessed → Maybe[a]

Given a $key and either a HashRef or a blessed $object, returns the attribute
value for that $key. Equivalent to:

    $hashref->{$key} or $blessed_object->$key()

    prop('x', {x => 100}); # 100
    prop('x', {}); # undef
    prop('x', undef); # throws exception

## prop\_eq

    Str → a → HashRef → Bool

Returns 1 if the specified object property is equal, in equals terms, to the
given value; empty string otherwise.

    prop_eq('a', 2)->({ a => 2 }); # 1
    prop_eq('a', 4)->({ a => 2 }); # ''

## range

    Num → Num → [Num]

## reduce

    (a → b → a) → a → [b] → a

Returns a single item by iterating through the list, successively calling the
iterator function and passing it an accumulator value and the current value from
the array, and then passing the result to the next call.

The iterator function receives two values: (acc, value).

    reduce(subtract, 0, [1, 2, 3, 4]) # ((((0 - 1) - 2) - 3) - 4) = -10

## reduced

    * -> Yoda::Reduced

Returns a value wrapped to indicate that it is the final value of the reduce
and transduce functions.

    my $reducer = sub {
        my $sum = sum(\@_);
        return $sum >= 10 ? reduced($sum) : $sum;
    };

    reduce($reducer, 0, [ 1..5 ]); # 10

## reduce\_by

    ((a, b) → a) → a → (b → Str) → [b] → {Str: a}

## reject

    Filterable f => (a → Bool) → f a → f a

The complement of filter.

    my $is_odd = sub { $_[0] % 2 == 1 };

    reject($is_odd, [1, 2, 3, 4]); # [2, 4]

    reject($is_odd, {a => 1, b => 2, c => 3, d => 4});
    # {b => 2, d => 4}

## replace

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

## subtract

    Num → Num → Num

Subtracts its second argument from its first argument.

    subtract(10, 8); # 2

    my $minus_5 = subtract(__, 5);
    $minus_5->(17); # 12

    my $complementary_angle = subtract(90);
    $complementary_angle->(30); # 60
    $complementary_angle->(72); # 18

## sum

    [Num] → Num

Adds together all the elements of a list.

    sum([2,4,6,8,100,1]); # 121

## T

    * → Bool

A function that always returns 1. Any passed in parameters are ignored.

    T(); # 1

## take

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

## to\_lower

    Str → Str

Returns the lower case version of a string.

    to_lower('ABC'); # abc

## to\_upper

    Str → Str

Returns the upper case version of a string.

    to_upper('abc'); # 'ABC'

## transduce

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

## transpose

    [[a]] → [[a]]

Transposes the rows and columns of a 2D list. When passed a list of n lists of
length x, returns a list of x lists of length n.

    transpose([[1, 'a'], [2, 'b'], [3, 'c']]),
    [[1, 2, 3], ['a', 'b', 'c']],

If some of the rows are shorter than the following rows, their elements are
skipped:

    transpose([[10, 11], [20], [], [30, 31, 32]]),
    [[10, 20, 30], [11, 31], [32]],

## try\_catch

    (…x → a) → ((e, …x) → a) → (…x → a)

try\_catch takes two functions, a tryer and a catcher. The returned function
evaluates the tryer; if it does not throw, it simply returns the result. If the
tryer does throw, the returned function evaluates the catcher function and
returns its result. Note that for effective composition with this function, both
the tryer and catcher functions must return the same type of results.

    try_catch(prop('x'), F())({x => 1}); # 1
    try_catch(prop('x'), F())(undef); # ''

## type

    * -> Str

Gives a single-word string description of the type of a value, returning such
answers as 'Hash', 'Integer', 'Array', or 'Undef'.

    type({}); # Hash
    type(1); # Integer
    type(1.0); # Float
    type('1'); # String
    type(undef); # Undef
    type([]); # Array
    type(qr/[A-z]/); # Regexp
    type(type()); # Code
    type(bless({}, 'Animal::Dog')); # 'Animal::Dog'

## unapply

    ([*…] → a) → (*… → a)

Takes a function fn, which takes a single array argument, and returns a
function which:

\* takes any number of positional arguments;
\* passes these arguments to fn as an array; and
\* returns the result.

In other words, unapply derives a variadic function from a function which
takes an array. unapply is the inverse of apply.

    my $join_with_space = Yoda::join(' ');

    unapply($join_with_space)->('hello', 'world'); # 'hello world'

## unfold

    (a → [b]) → * → [b]

Builds a list from a seed value. Accepts an iterator function, which returns
either a falsey value to stop iteration or an array of length 2 containing the
value to add to the resulting list and the seed to be used in the next call to
the iterator function.

The iterator function receives one argument: (seed).

    my $f = sub { my ($n) = @_; $n > 50 ? '' : [-$n, $n + 10] };

    unfold($f, 10); # [-10, -20, -30, -40, -50];

## uniq

    [a] → [a]

Returns a new list containing only one copy of each element in the original
list.

Order is not preserved for performance reasons.

    uniq([1, 1, 2, 1]); # [1, 2]
    uniq([1, '1']);     # [1, '1']
    uniq([[42], [42]]); # [[42]]

## union

    [*] → [*] → [*]

Combines two lists into a set (i.e. no duplicates) composed of the elements of
each list.

Order is not preserved for performance reasons.

    my $union = union([1, 2, 3], [2, 3, 4, '2']);

    scalar @$union; # 5

    $union; # [1, 2, 3, 4, '2'] (but probably not in this order)

## values

    Hashref[*] → [*]

Returns an ArrayRef of values from the supplied HashRef. The values can be
returned in any order.

    values({ a => 1, b => 3, c => 2 }); # [3, 2, 1]

## where\_eq

    HashRef[a] → HashRef[b] → Bool

Takes a $spec object and a $test object; returns 1 if the test satisfies the
spec, undef otherwise. An object satisfies the spec if, for each of the specs
own properties, accessing that property of the test object gives the same value
(in Yoda::equals terms) as accessing that property of the spec.

    my $pred = where_eq({ a => 1, b => 2 });

    $pred->({ a => 1 });                    # undef
    $pred->({ a => 1, b => 2 });            # 1
    $pred->({ a => 1, b => 2, c => 3 });    # 1
    $pred->({ a => 1, b => 1 });            # undef
    $pred->({ a => '1', b => '2' });        # undef

## zip\_with

    (a → b → c) → [a] → [b] → [c]

Creates a new list out of the two supplied by applying the function to each
equally-positioned pair in the lists. The returned list is truncated to the
length of the shorter of the two input lists.

    my $f = sub { my ($x, $y) = @_; … };

    zipWith($f, [1, 2, 3], ['a', 'b', 'c']);
    # [f->(1, 'a'), f->(2, 'b'), f->(3, 'c')]

# LICENSE

Copyright (C) Keith Broughton.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Keith Broughton `<keithbro [AT] cpan.org>`
