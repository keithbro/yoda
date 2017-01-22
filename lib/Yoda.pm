package Yoda;
use 5.008001;
use strict;
use warnings;

use Test::Deep::NoTest qw(cmp_details superhashof);

our $VERSION = "0.01";

=head1 NAME

Yoda - Perl port of Ramda

=head1 SYNOPSIS

    use Yoda;

=head1 DESCRIPTION

Yoda is a practical functional library for Perl programmers.

=head1 FUNCTIONS

=head2 filter

    Filterable f => (a -> Bool) -> f a -> f a

=cut

sub filter {
    _curry2(sub {
        my ($predicate, $filterable) = @_;
        return [ grep { $predicate->($_) } @$filterable ];
    }, @_);
}

=head2 head

    [a] -> a | undef
    Str -> Str

=cut

sub head {
    _curry_n(1, sub {
        my ($list_or_string) = @_;
        return ref($list_or_string)
            ? $list_or_string->[0]
            : substr($list_or_string, 0, 1);
    }, @_);
}

=head2 juxt

    [(a, b, ..., m) -> n] -> ((a, b, ..., m) -> [n])

=cut

sub juxt {
    _curry2(sub {
        my ($functions, @args) = @_;
        return [ map { $_->(@args) } @$functions ];
    }, @_);
}

=head2 map

    Functor f => (a -> b) -> f a -> f b

=cut

sub map {
    _curry2(sub {
        my ($function, $functor) = @_;
        return [ map { $function->($_) } @$functor ];
    }, @_);
}

=head2 partition

    Filterable f => (a -> Bool) -> f a -> [f a, f a]

=cut

sub partition {
    _curry2(sub {
        my ($predicate, $filterable) = @_;
        return juxt( [ \&filter, \&reject ], $predicate, $filterable );
    }, @_);
}

=head2 reject

    Filterable f => (a -> Bool) -> f a -> f a

=cut

sub reject {
    _curry2(sub {
        my ($predicate, $filterable) = @_;
        return [ grep { !$predicate->($_) } @$filterable ];
    }, @_);
}

=head2 where_eq

    {Str: *} -> {Str: *} -> Bool

=cut

sub where_eq {
    _curry2(sub {
        my ($spec, $test) = @_;
        my ($ok) = cmp_details($test, superhashof($spec));
        return $ok;
    }, @_);
}

sub _curry1 { _curry_n(1, @_) }
sub _curry2 { _curry_n(2, @_) }
sub _curry3 { _curry_n(3, @_) }

sub _curry_n {
    my ($arity, $func, @args) = @_;

    if (scalar @args >= $arity) {
        return $func->(@args);
    }

    return sub { $func->(@args, @_) };
}

1;

=head1 LICENSE

Copyright (C) Keith Broughton.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Keith Broughton C<< <keithbro [AT] cpan.org> >>

=cut

