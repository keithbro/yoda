use Test::Most;

use Yoda qw(assoc);

subtest HashRef => sub {
    eq_or_diff(
        assoc('c', 42, {}),
        { c => 42 },
    );

    eq_or_diff(
        assoc('c', 42, { c => 5 }),
        { c => 42 },
    );

    eq_or_diff(
        assoc('c', 42, {a => 1, b => 2}),
        {a => 1, b => 2, c => 42},
    );
};

subtest ArrayRef => sub {

    eq_or_diff(
        assoc(2, 42, []),
        [undef, undef, 42],
        'sparse array',
    );

    eq_or_diff(
        assoc(2, 42, [1, 2, 3, 4, 5]),
        [1, 2, 42, 4, 5],
        'replace',
    );

    eq_or_diff(
        assoc(-1, 42, [1, 2, 3, 4, 5]),
        [1, 2, 3, 4, 42],
        'negative indices',
    );

};

done_testing;
