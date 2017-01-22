use Test::Most;

use lib 't/lib';

use Data::Dumper;

use Yoda;
use Yoda::Test;

my $tasks = Yoda::Test::tasks;

eq_or_diff(
    Yoda::group_by( Yoda::prop('username'), $tasks ),
    {
        keith => [ $tasks->[0] ],
        rachel => [ $tasks->[1] ],
        shane => [ $tasks->[2], $tasks->[3] ],
    },
    'group_by',
);

done_testing;
