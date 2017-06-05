use Test::Most;

use Yoda qw(assoc_path);

subtest 'HashRef' => sub {

    eq_or_diff(
        assoc_path([], 42, {}),
        {},
        'empty path',
    );

    eq_or_diff(
        assoc_path(['a'], 42, {}),
        { a => 42 },
        'one key in path',
    );

    eq_or_diff(
        assoc_path(['a', 'b'], 42, {}),
        { a => { b => 42 } },
        'two keys in path',
    );

    eq_or_diff(
        assoc_path(['a', 'b', 'c'], 42, {a => {b => {c => 0}}, d => 1}),
        {a => {b => {c => 42}}, d => 1},
        'overwrite value',
    );

};

subtest ArrayRef => sub {
    eq_or_diff(
        assoc_path([], 42, []),
        [],
        'empty path',
    );

    eq_or_diff(
        assoc_path([1], 42, []),
        [undef, 42],
        'one key in path',
    );

    eq_or_diff(
        assoc_path([2, 2], 42, []),
        [undef, undef, { 2 => 42 }],
        'default autovivification is HashRef',
    );

    eq_or_diff(
        assoc_path([2, 2], 42, [undef, undef, []]),
        [undef, undef, [undef, undef, 42]],
        'nested arrays',
    );

};

subtest MixedRef => sub {
    eq_or_diff(
        assoc_path(['n', -1], 42, { n => [1, 2, 3, 4, 5] }),
        { n => [ 1, 2, 3, 4, 42 ] },
        'negative indices',
    );

};

done_testing;
