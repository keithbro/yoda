use Test::Most;

use Yoda qw(assoc_path);

eq_or_diff(
    assoc_path(['a', 'b', 'c'], 42, {a => {b => {c => 0}}}),
    {a => {b => {c => 42}}},
    'normal path',
);

eq_or_diff(
    assoc_path(['a', 'b', 'c'], 42, {a => 5}),
    {a => {b => {c => 42}}},
    'overwrite',
);

eq_or_diff(
    assoc_path(['n', -1], 42, { n => [1, 2, 3, 4, 5] }),
    { n => [ 1, 2, 3, 4, 42 ] },
    'negative indices',
);

done_testing;
