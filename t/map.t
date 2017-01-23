use Test::Most;

use Yoda;

my $double = sub { shift() * 2 };

eq_or_diff(
    Yoda::map($double, [1, 2, 3]),
    [2, 4, 6],
    'map over ArrayRef',
);

eq_or_diff(
    Yoda::map($double, {x => 1, y => 2, z => 3}),
    {x => 2, y => 4, z => 6},
    'map over HashRef',
);

done_testing;
