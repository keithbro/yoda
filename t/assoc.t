use Test::Most;

use Yoda qw(assoc);

eq_or_diff(
    assoc('c', 3, {a => 1, b => 2}),
    {a => 1, b => 2, c => 3},
    'normal',
);

eq_or_diff(
    assoc(-1, 42, [1, 2, 3, 4, 5]),
    [1, 2, 3, 4, 42],
    'negative indices',
);

done_testing;
