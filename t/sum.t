use Test::Most;

use Yoda qw(sum);

is sum( [ 2, 4, 6, 8, 100, 1 ] ), 121;

done_testing;
