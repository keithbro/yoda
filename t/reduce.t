use Test::Most;

use Yoda;

is(
    Yoda::reduce(Yoda::subtract, 0, [1, 2, 3, 4]), -10,
    'reduce + subtract',
);

done_testing;
