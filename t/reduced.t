use Test::Most;

use Yoda qw(reduce reduced sum);

my $reducer = sub {
    my $sum = sum(\@_);
    return $sum >= 10 ? reduced($sum) : $sum;
};

is reduce($reducer, 0, [ 1..5 ]), 10, 'stopped summation at 10';

done_testing;
