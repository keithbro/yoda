package Yoda;
use 5.008001;
use strict;
use warnings;

use Exporter 'import';
use JSON::XS qw(encode_json);
use Test::Deep::NoTest qw(cmp_details superhashof);
use Try::Tiny;

our $VERSION = "0.01";

our @EXPORT_OK = qw(always append cond equals T);

=head1 NAME

Yoda - Perl port of Ramda

=head1 SYNOPSIS

    use Yoda;

=head1 DESCRIPTION

Yoda is a practical functional library for Perl programmers.

=head1 FUNCTIONS

=head2 always

    a -> (* -> a)

Returns a function that always returns the given value.

    my $t = always('Tee');
    $t->(); # 'Tee'

=cut

sub always {
    _curry1(sub {
        my ($const) = @_;
        sub { $const }
    }, @_);
}

=head2 append

    a -> [a] -> [a]

Returns a new list containing the contents of the given list, followed by the
given element.

    append('tests', ['write', 'more']);     # ['write', 'more', 'tests']
    append('tests', []);                    # ['tests']
    append(['tests'], ['write', 'more']);   # ['write', 'more', ['tests']]

=cut

sub append {
    _curry2(sub {
        my ($element, $list) = @_;
        return [ @$list, $element ];
    }, @_);
}

=head2 cond

    [[(*... -> Bool),(*... -> *)]] -> (*... -> *)

Returns a function, fn, which encapsulates if/else, if/else, ... logic. `cond`
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

=head2 memoize

    (*... -> a) -> (*... -> a)

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

=head2 partition

    Filterable f => (a -> Bool) -> f a -> [f a, f a]

=cut

sub partition {
    _curry2(sub {
        my ($predicate, $filterable) = @_;
        return juxt( [ filter(), reject() ], $predicate, $filterable );
    }, @_);
}

=head2 product

    [Num] -> Num

=cut

sub product {
    _curry1(sub {
        my ($numbers) = @_;

        my $value = 1;
        $value = $value * $_ for @$numbers;

        return $value;
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

=head2 range

    Num -> Num -> [Num]

=cut

sub range {
    _curry2(sub {
        my ($from, $to) = @_;
        return [ $from .. $to ];
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

=head2 try_catch

    (...x -> a) -> ((e, ...x) -> a) -> (...x -> a)

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

=head2 uniq

    [a] -> [a]

=cut

sub uniq {
    _curry1(sub {
        my ($elements) = @_;
        my $element_for_string = _uniq($elements);
        return [ values %$element_for_string ];
    }, @_);
}

=head2 union

    [*] -> [*] -> [*]

=cut

sub union { _curry2(sub { uniq( [ map { @$_ } @_ ] ) }, @_) }

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

# _uniq
#
#    [a] -> {Str: a}
#
# Given a list, returns a HashRef where the keys are a unique Str representation
# of each element and the values are the (unique) elements.

sub _uniq {
    _curry1(sub {
        my ($elements) = @_;
        return { map { ref($_) ? encode_json($_) : $_ => $_ } @$elements };
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

