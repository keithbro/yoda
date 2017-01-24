use Test::Most;

use Yoda qw(concat);

is concat('ABC', 'DEF'), 'ABCDEF', 'concat string';
eq_or_diff concat([4, 5, 6], [1, 2, 3]), [4, 5, 6, 1, 2, 3], 'concat array';
eq_or_diff concat([], []), [], 'concat empty array';

done_testing;
