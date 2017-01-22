use Test::Most;

use Yoda;

eq_or_diff(
    Yoda::intersection([1,2,3,4,4], [8,7,6,5,4,3]), [3, 4],
    'intersection, first is smaller',
);

eq_or_diff(
    Yoda::intersection([1,2,3,4,5,6], [8,7,6]), [6],
    'intersection, second is smaller',
);

done_testing;
