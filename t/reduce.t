use Test::Most;

use Yoda qw(reduce subtract);

is(
    reduce(subtract, 0, [1, 2, 3, 4]), -10,
    'reduce + subtract',
);

done_testing;
