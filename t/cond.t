use Test::Most;

use Yoda qw(always cond equals T);

my $fn = Yoda::cond([
    [equals(0)  , always('water freezes at 0°C')],
    [equals(100), always('water boils at 100°C')],
    [T(), sub { 'nothing special happens at ' . shift() . '°C' }],
]);

is $fn->(0), 'water freezes at 0°C', 'match first';
is $fn->(50), 'nothing special happens at 50°C', 'match last';
is $fn->(100), 'water boils at 100°C', 'match second';

$fn = cond([]);

is $fn->(1), undef, 'no match';

done_testing;
