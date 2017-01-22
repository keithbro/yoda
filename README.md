[![Build Status](https://travis-ci.org/keithbro/yoda.svg?branch=master)](https://travis-ci.org/keithbro/yoda)
# NAME

Yoda - Perl port of Ramda

# SYNOPSIS

    use Yoda;

# DESCRIPTION

Yoda is a practical functional library for Perl programmers.

# FUNCTIONS

## filter

    Filterable f => (a -> Bool) -> f a -> f a

## head

    [a] -> a | undef
    Str -> Str

## juxt

    [(a, b, ..., m) -> n] -> ((a, b, ..., m) -> [n])

## map

    Functor f => (a -> b) -> f a -> f b

## partition

    Filterable f => (a -> Bool) -> f a -> [f a, f a]

## reject

    Filterable f => (a -> Bool) -> f a -> f a

## where\_eq

    {Str: *} -> {Str: *} -> Bool

# LICENSE

Copyright (C) Keith Broughton.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Keith Broughton `<keithbro [AT] cpan.org>`
