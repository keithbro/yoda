use Test::Most;

use lib 't/lib';

use Yoda;
use Yoda::Test;

my $tasks = Yoda::Test::tasks();

cmp_bag(
    Yoda::intersection([1,2,3,4,4], [8,7,6,5,4,3]),
    [3, 4],
    'intersection, first is smaller',
);

cmp_bag(
    Yoda::intersection([1,2,3,4,5,6], [8,7,6]),
    [6],
    'intersection, second is smaller',
);

cmp_bag(
    Yoda::intersection($tasks, []),
    [],
    'intersection, hashrefs',
);

cmp_bag(
    Yoda::intersection($tasks, [$tasks->[0]]),
    [$tasks->[0]],
    'intersection, hashrefs',
);


done_testing;
