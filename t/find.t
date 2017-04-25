use Test::Most;

use Yoda qw(find prop_eq);

my $xs = [{a => 1}, {a => 2}, {a => 3}];

eq_or_diff(
    find(prop_eq('a', 2))->($xs),
    {a => 2},
);

eq_or_diff(
    find(prop_eq('a', 4))->($xs),
    undef,
);

done_testing;
