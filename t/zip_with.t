use Test::Most;

use Yoda qw(zip_with);

my $f = sub { my ($n, $c) = @_; return "$c$n" };

eq_or_diff(
    zip_with($f, [1, 2, 3, 4], ['a', 'b', 'c']),
    [ 'a1', 'b2', 'c3' ],
);

done_testing;
