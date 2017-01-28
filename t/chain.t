use Test::Most;

use Yoda qw(append chain head);

my $duplicate = sub { [ $_[0], $_[0] ] };

eq_or_diff(
    chain($duplicate, [1, 2, 3]),
    [1, 1, 2, 2, 3, 3],
    '((a -> [a]) -> [a]) -> [a]',
);

eq_or_diff(
    chain($duplicate)->([1, 2, 3]),
    [1, 1, 2, 2, 3, 3],
    '((a -> [a])) -> [a] -> [a]',
);

eq_or_diff(
    chain(append(), head())->([1, 2, 3]),
    [1, 2, 3, 1],
    '((a -> [a]) -> ([a] -> a)) -> [a] -> [a]',
);

eq_or_diff(
    chain(append(), head(), [1, 2, 3]),
    [1, 2, 3, 1],
    '((a -> [a]) -> ([a] -> a) -> [a]) -> [a]',
);

eq_or_diff(
    chain(append())->(head(), [1, 2, 3]),
    [1, 2, 3, 1],
    '((a -> [a])) -> (([a] -> a) -> [a]) -> [a]',
);

eq_or_diff(
    chain(append())->(head())->([1, 2, 3]),
    [1, 2, 3, 1],
    '((a -> [a])) -> (([a] -> a)) -> ([a]) -> [a]',
);

done_testing;

