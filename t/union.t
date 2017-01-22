use Test::Most;

use lib 't/lib';

use Yoda;
use Yoda::Test;

my $tasks = Yoda::Test::tasks();

cmp_bag(
    Yoda::union([1, 2], [3]),
    [1, 2, 3],
    'union numbers',
);

cmp_bag(
    Yoda::union($tasks, []),
    $tasks,
    'union',
);

done_testing;
