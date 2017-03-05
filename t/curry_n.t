use Test::Most;

use Yoda qw(curry_n sum);

my $sum_args = sub { sum(\@_) };
#my $sum_args = sub {
#    my $sum = 0;
#    $sum += $_ for @_;
#    return $sum;
#};
is $sum_args->(1,2,3,4), 10, 'sanity check';

my $curried_add_four_numbers = curry_n(4, $sum_args);
my $f = $curried_add_four_numbers->(1, 2);
my $g = $f->(3);
is $g->(4), 10;

done_testing;
