use Test::Most;

use Yoda;

eq_or_diff(
    Yoda::filter(sub { shift() % 3 == 0 }, [ 2, 4, 6, 8 ]),
    [ 6 ],
    'filter over array',
);

done_testing;
