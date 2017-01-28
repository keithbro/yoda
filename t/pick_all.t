use Test::Most;

use Yoda qw(pick_all);

my $hash_ref = { a => 1, b => 2, c => 3, d => 4, e => 0 };

eq_or_diff(
    pick_all(['a', 'd'], $hash_ref),
    { a => 1, d => 4 },
    'pick_all',
);

eq_or_diff(
    pick_all(['a', 'e', 'f'], $hash_ref),
    { a => 1, e => 0, f => undef },
    'pick_all returns undef',
);

done_testing;
