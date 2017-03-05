use Test::Most;

use Yoda qw(values);

cmp_bag values({ a => 1, b => 3, c => 2 }), [1, 3, 2];

done_testing;
