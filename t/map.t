use Test::Most;

use Yoda;

eq_or_diff(
    Yoda::map(sub { shift() * 3 }, [ 2, 4, 6, 8 ]),
    [ 6, 12, 18, 24 ],
    'map over array',
);

done_testing;
