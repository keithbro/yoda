use Test::Most;

use Yoda qw(uniq);

cmp_bag uniq([1, 1, 2, 1]), [1, 2];
cmp_bag uniq([1, '1']), [1, '1'];
cmp_bag uniq([[42], [42]]), [[42]];

done_testing;
