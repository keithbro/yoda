[![Build Status](https://travis-ci.org/keithbro/yoda.svg?branch=master)](https://travis-ci.org/keithbro/yoda)
# NAME

Yoda - Perl port of Ramda

# SYNOPSIS

    use Yoda;

# DESCRIPTION

Yoda is a practical functional library for Perl programmers.

# FUNCTIONS

## always

    a -> (* -> a)

Returns a function that always returns the given value.

    my $t = always('Tee');
    $t->(); # 'Tee'

## append

    a -> [a] -> [a]

Returns a new list containing the contents of the given list, followed by the
given element.

    append('tests', ['write', 'more']);     # ['write', 'more', 'tests']
    append('tests', []);                    # ['tests']
    append(['tests'], ['write', 'more']);   # ['write', 'more', ['tests']]

## cond

    [[(*... -> Bool),(*... -> *)]] -> (*... -> *)

Returns a function, fn, which encapsulates if/else, if/else, ... logic. \`cond\`
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

    a -> [a] -> Bool

Returns 1 if the specified value is equal, in \`equals\` terms, to at least one
element of the given list; or the empty string otherwise.

    contains(3, [1, 2, 3]); # 1
    contains(4, [1, 2, 3]); # ''
    contains({ name: 'Fred' }, [{ name: 'Fred' }]); # 1
    contains([42], [[42]]); # 1

## equals

    a -> b -> Bool

Returns 1 if its arguments are equivalent, the empty string otherwise. Currently
does not handles cyclical data structures, unlike Ramda.

    equals(1, 1); # 1
    equals(1, '1'); # ''
    equals([1, 2, 3], [1, 2, 3]); # 1

## filter

    Filterable f => (a -> Bool) -> f a -> f a

Takes a predicate and a "filterable", and returns a new filterable of the same
type containing the members of the given filterable which satisfy the given
predicate.

    my $isEven = sub { shift() % 2 == 0 };

    filter($isEven, [1, 2, 3, 4]); # [2, 4]

    filter($isEven, {a => 1, b => 2, c => 3, d => 4}); # {b => 2, d => 4}

## group\_by

    (a -> Str) -> [a] -> {Str: [a]}

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
        # ...
        {name => 'Jack', score => 69},
    ];

    $by_grade->($students);
    # {
    #     'B' => [{name => 'Abby', score => 84}],
    #     'D' => [{name => 'Jack', score => 69}],
    #     ...
    #     'F' => [{name => 'Eddy', score => 58}],
    # },

## head

    [a] -> a | undef
    Str -> Str

Returns the first element of the given list or string.

    head(['fi', 'fo', 'fum']); # 'fi'
    head([]); # undef

    head('abc'); # 'a'
    head(''); # ''

## intersection

    [*] -> [*] -> [*]

Combines two lists into a set (i.e. no duplicates) composed of those elements
common to both lists.

    intersection([1,2,3,4], [7,6,5,4,3]); # [4, 3]

## juxt

    [(a, b, ..., m) -> n] -> ((a, b, ..., m) -> [n])

juxt applies a list of functions to a list of values.

    my $get_range = juxt([min(), max()]);
    $get_range->(3, 4, 9, -3); # [-3, 9]

## map

    Functor f => (a -> b) -> f a -> f b

Takes a function and a functor, applies the function to each of the functor's
values, and returns a functor of the same shape.

Yoda provides suitable map implementations for ArrayRef and HashRef, so this
function may be applied to \[1, 2, 3\] or {x => 1, y => 2, z => 3}.

    my $double = sub { shift() * 2 };

    Yoda::map($double, [1, 2, 3]) # [2, 4, 6]

    Yoda::map($double, {x => 1, y => 2, z => 3}) # {x => 2, y => 4, z => 6}

## max

    [Num] -> Num

Returns the larger of its two arguments.

    R.max(789, 123); # 789

## memoize

    (*... -> a) -> (*... -> a)

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

    [Num] -> Num

Returns the smaller of its two arguments.

    R.min(789, 123); # 123

## partition

    Filterable f => (a -> Bool) -> f a -> [f a, f a]

## product

    [Num] -> Num

## prop

    s -> {s: a} -> a | Undefined

## range

    Num -> Num -> [Num]

## reduce

    ((a, b) -> a) -> a -> [b] -> a

## reduce\_by

    ((a, b) -> a) -> a -> (b -> Str) -> [b] -> {Str: a}

## reject

    Filterable f => (a -> Bool) -> f a -> f a

## subtract

    Num -> Num -> Num

## T

    * -> Bool

## transpose

    [[a]] -> [[a]]

## try\_catch

    (...x -> a) -> ((e, ...x) -> a) -> (...x -> a)

## unfold

    (a -> [b]) -> * -> [b]

Builds a list from a seed value. Accepts an iterator function, which returns
either a falsey value to stop iteration or an array of length 2 containing the
value to add to the resulting list and the seed to be used in the next call to
the iterator function.

The iterator function receives one argument: (seed).

    my $f = sub { my ($n) = @_; $n > 50 ? '' : [-$n, $n + 10] };

    unfold($f, 10); # [-10, -20, -30, -40, -50];

## uniq

    [a] -> [a]

## union

    [*] -> [*] -> [*]

## where\_eq

    {Str: *} -> {Str: *} -> Bool

## zip\_with

    (a -> b -> c) -> [a] -> [b] -> [c]

Creates a new list out of the two supplied by applying the function to each
equally-positioned pair in the lists. The returned list is truncated to the
length of the shorter of the two input lists.

    my $f = sub { my ($x, $y) = @_; ... };

    zipWith($f, [1, 2, 3], ['a', 'b', 'c']);
    # [f->(1, 'a'), f->(2, 'b'), f->(3, 'c')]

# LICENSE

Copyright (C) Keith Broughton.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Keith Broughton `<keithbro [AT] cpan.org>`
