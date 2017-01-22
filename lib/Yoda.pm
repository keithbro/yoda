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

=head2 always

    a -> (* -> a)

=cut

sub always {
    _curry1(sub {
        my ($const) = @_;
        sub { $const }
    }, @_);
}

=head2 append

    a -> [a] -> [a]

=cut

sub append {
    _curry2(sub {
        my ($element, $values) = @_;
        return [ @$values, $element ];
    }, @_);
}

=head2 cond

    [[(*... -> Bool),(*... -> *)]] -> (*... -> *)

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

=head2 equals

    a -> b -> Bool

=cut

sub equals {
    _curry2(sub {
        my ($x, $y) = @_;
        my ($ok) = cmp_details($x, $y);
        return $ok;
    }, @_);
}

=head2 filter

    Filterable f => (a -> Bool) -> f a -> f a

=cut

sub filter {
    _curry2(sub {
        my ($predicate, $filterable) = @_;
        return [ grep { $predicate->($_) } @$filterable ];
    }, @_);
}

=head2 group_by

    (a -> Str) -> [a] -> {Str: [a]}

=cut

sub group_by {
    _curry2(sub {
        my ($function, $elements) = @_;
        return reduce_by(append(), [], $function, $elements);
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

=head2 intersection

    [*] -> [*] -> [*]

=cut

sub intersection {
    _curry2(sub {
        my ($x, $y) = @_;

        my $is_element_in_x = { map { $_ => 1 } @$x };
        my $is_element_in_y = { map { $_ => 1 } @$y };

        my ($lookup, $filter);
        if (scalar @$x < scalar @$y) {
            $lookup = $is_element_in_x;
            $filter = $is_element_in_y;
        } else {
            $lookup = $is_element_in_y;
            $filter = $is_element_in_x;
        }

        return [ sort grep { $lookup->{$_} } keys %$filter ];
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

=head2 prop

    s -> {s: a} -> a | Undefined

=cut

sub prop {
    _curry2(sub {
        my ($key, $hashref) = @_;
        return $hashref->{$key};
    }, @_);
}

=head2 reduce

    ((a, b) -> a) -> a -> [b] -> a

=cut

sub reduce {
    _curry3(sub {
        my ($func, $initial_value, $elements) = @_;
        List::Util::reduce { $func->($a, $b) } $initial_value, @$elements;
    }, @_);
}

=head2 reduce_by

    ((a, b) -> a) -> a -> (b -> Str) -> [b] -> {Str: a}

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

    Filterable f => (a -> Bool) -> f a -> f a

=cut

sub reject {
    _curry2(sub {
        my ($predicate, $filterable) = @_;
        return [ grep { !$predicate->($_) } @$filterable ];
    }, @_);
}

=head2 subtract

    Num -> Num -> Num

=cut

sub subtract { _curry2(sub { shift() - shift() }, @_) }

=head2 T

    * -> Bool

=cut

sub T { sub { 1 } }

=head2 transpose

    [[a]] -> [[a]]

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

