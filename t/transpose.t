use Test::Most;

use Yoda qw(transpose);

eq_or_diff(
    transpose([[1, 'a'], [2, 'b'], [3, 'c']]),
    [[1, 2, 3], ['a', 'b', 'c']],
    'transpose',
);

eq_or_diff(
    transpose([[10, 11], [20], [], [30, 31, 32]]),
    [[10, 20, 30], [11, 31], [32]],
    'transpose lists of different sizes',
);

done_testing;
