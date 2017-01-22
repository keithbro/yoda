use Test::Most;

use Yoda;

my $fn = Yoda::cond([
    [Yoda::equals(0)  , Yoda::always('water freezes at 0°C')],
    [Yoda::equals(100), Yoda::always('water boils at 100°C')],
    [Yoda::T(), sub { 'nothing special happens at ' . shift() . '°C' }],
]);

is $fn->(0), 'water freezes at 0°C', 'match first';
is $fn->(50), 'nothing special happens at 50°C', 'match last';
is $fn->(100), 'water boils at 100°C', 'match second';

$fn = Yoda::cond([]);

is $fn->(1), undef, 'no match';

done_testing;
