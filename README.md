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

## append

    a -> [a] -> [a]

## cond

    [[(*... -> Bool),(*... -> *)]] → (*... -> *)

## equals

    a -> b -> Bool

## filter

    Filterable f => (a -> Bool) -> f a -> f a

## group\_by

    (a -> Str) -> [a] -> {Str: [a]}

## head

    [a] -> a | undef
    Str -> Str

## juxt

    [(a, b, ..., m) -> n] -> ((a, b, ..., m) -> [n])

## map

    Functor f => (a -> b) -> f a -> f b

## partition

    Filterable f => (a -> Bool) -> f a -> [f a, f a]

## prop

    s -> {s: a} -> a | Undefined

## reduce\_by

    ((a, b) -> a) -> a -> (b -> Str) -> [b] -> {Str: a}

## reject

    Filterable f => (a -> Bool) -> f a -> f a

## T

    * -> Bool

## transpose

    [[a]] -> [[a]]

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

- Around line 52:

    Non-ASCII character seen before =encoding in '→'. Assuming UTF-8
