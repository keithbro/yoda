package Yoda;
use 5.008001;
use strict;
use warnings;

our $VERSION = "0.01";

=head2 map

    Functor f => (a → b) -> f a -> f b

=cut

sub map {
    _curry2(sub {
        my ($function, $functor) = @_;
        return [ map { $function->($_) } @$functor ];
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
__END__

=encoding utf-8

=head1 NAME

Yoda - It's new $module

=head1 SYNOPSIS

    use Yoda;

=head1 DESCRIPTION

Yoda is ...

=head1 LICENSE

Copyright (C) Keith Broughton.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Keith Broughton E<lt>keithbro256@gmail.comE<gt>

=cut

