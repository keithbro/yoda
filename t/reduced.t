use Test::Most;

use Yoda qw(reduce reduced);

my $reducer = sub {
    my ($prev, $next) = @_;
    return $prev >= 10 ? reduced() : $prev + $next;
};

is reduce($reducer, 0, [ 1..5 ]), 10, 'stopped summation at 10';

done_testing;
