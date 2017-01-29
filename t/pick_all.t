use Test::Most;

use Yoda qw(pick_all);

my $hash_ref = { a => 1, b => 2, c => 3, d => 4, e => 0 };
my $array_ref = [ sort keys %$hash_ref ];

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

eq_or_diff(
    pick_all([0, 2, 99], $array_ref),
    { 0 => 'a', 2 => 'c', 99 => undef },
    'pick_all from array_ref',
);

done_testing;
