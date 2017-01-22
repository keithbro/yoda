use Test::Most;

use lib 't/lib';

use Data::Dumper;

use Yoda;
use Yoda::Test;

my $tasks = Yoda::Test::tasks;

my $where_complete = Yoda::where_eq( { complete => 1 } );

eq_or_diff(
    Yoda::partition($where_complete, $tasks),
    [
        [ $tasks->[0], $tasks->[2] ],
        [ $tasks->[1], $tasks->[3] ],
    ],
    'partition',
);

done_testing;
