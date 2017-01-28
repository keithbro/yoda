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

## add

    Num → Num → Num

Adds two numbers.

    add(3, -10); # -7

## always

    a → (* → a)

Returns a function that always returns the given value.

    my $t = always('Tee');
    $t->(); # 'Tee'

## append

    a → [a] → [a]

Returns a new list containing the contents of the given list, followed by the
given element.

    append('tests', ['write', 'more']);     # ['write', 'more', 'tests']
    append('tests', []);                    # ['tests']
    append(['tests'], ['write', 'more']);   # ['write', 'more', ['tests']]

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
    contains(4, [1, 2, 3]); # ''
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

## intersection

    [*] → [*] → [*]

Combines two lists into a set (i.e. no duplicates) composed of those elements
common to both lists.

    intersection([1,2,3,4], [7,6,5,4,3]); # [4, 3]

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

## product

    [Num] → Num

## sum

    [Num] → Num

Adds together all the elements of a list.

    sum([2,4,6,8,100,1]); # 121

## prop

    s → {s: a} → a | undef

Returns a function that when supplied a HashRef returns the indicated value
of that HashRef, if it exists.

    prop('x', {x => 100}); # 100
    prop('x', {}); # undef

## range

    Num → Num → [Num]

## reduce

    (a → b → a) → a → [b] → a

Returns a single item by iterating through the list, successively calling the
iterator function and passing it an accumulator value and the current value from
the array, and then passing the result to the next call.

The iterator function receives two values: (acc, value).

    reduce(subtract, 0, [1, 2, 3, 4]) # ((((0 - 1) - 2) - 3) - 4) = -10

## reduce\_by

    ((a, b) → a) → a → (b → Str) → [b] → {Str: a}

## reject

    Filterable f => (a → Bool) → f a → f a

The complement of filter.

    my $is_odd = sub { $_[0] % 2 == 1 };

    reject($is_odd, [1, 2, 3, 4]); # [2, 4]

    reject($is_odd, {a => 1, b => 2, c => 3, d => 4});
    # {b => 2, d => 4}

## subtract

    Num → Num → Num

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

## transpose

    [[a]] → [[a]]

## try\_catch

    (…x → a) → ((e, …x) → a) → (…x → a)

try\_catch takes two functions, a tryer and a catcher. The returned function
evaluates the tryer; if it does not throw, it simply returns the result. If the
tryer does throw, the returned function evaluates the catcher function and
returns its result. Note that for effective composition with this function, both
the tryer and catcher functions must return the same type of results.

    try_catch(prop('x'), F())({x => 1}); # 1
    try_catch(prop('x'), F())(undef); # ''

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

## union

    [*] → [*] → [*]

## where\_eq

    {Str: *} → {Str: *} → Bool

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
