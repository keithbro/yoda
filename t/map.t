use Test::Most;

use Yoda qw(compose);

my $double = sub { shift() * 2 };

my $map_double = Yoda::map($double);

eq_or_diff(
    $map_double->([1, 2, 3]),
    [2, 4, 6],
    'map over ArrayRef',
);

eq_or_diff(
    $map_double->({x => 1, y => 2, z => 3}),
    {x => 2, y => 4, z => 6},
    'map over HashRef',
);

my $composed_maps = compose($map_double, $map_double);

eq_or_diff(
    $composed_maps->({ x => 1, y => 2, z => 3}),
    { x => 4, y => 8, z => 12 },
    'composed maps',
);

done_testing;
