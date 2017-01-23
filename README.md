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
    t(); # 'Tee'

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

## equals

    a -> b -> Bool

## filter

    Filterable f => (a -> Bool) -> f a -> f a

## group\_by

    (a -> Str) -> [a] -> {Str: [a]}

## head

    [a] -> a | undef
    Str -> Str

## intersection

    [*] -> [*] -> [*]

## juxt

    [(a, b, ..., m) -> n] -> ((a, b, ..., m) -> [n])

## map

    Functor f => (a -> b) -> f a -> f b

## memoize

    (*... -> a) -> (*... -> a)

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

## uniq

    [a] -> [a]

## union

    [*] -> [*] -> [*]

## where\_eq

    {Str: *} -> {Str: *} -> Bool

# LICENSE

Copyright (C) Keith Broughton.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Keith Broughton `<keithbro [AT] cpan.org>`

# POD ERRORS

Hey! **The above document had some coding errors, which are explained below:**

- Around line 78:

    Non-ASCII character seen before =encoding in '0°C')\],'. Assuming UTF-8
