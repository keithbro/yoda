use Test::Most;

use Yoda qw(flatten);

eq_or_diff(
    flatten([1, 2, [3, 4], 5, [6, [7, 8, [9, [10, 11], 12]]]]),
    [1..12],
);

done_testing;
