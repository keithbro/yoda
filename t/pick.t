use Test::Most;

use Yoda qw(pick);

my $hash_ref = { a => 1, b => 2, c => 3, d => 4, e => 0 };

eq_or_diff(
    pick(['a', 'd'], $hash_ref),
    { a => 1, d => 4 },
    'pick',
);

eq_or_diff(
    pick(['a', 'e', 'f'], $hash_ref),
    { a => 1, e => 0 },
    'pick never returns undef',
);

done_testing;
