use Test::Most;

use Yoda qw(__ subtract);

is subtract(10, 8), 2;

my $minus_5 = subtract(__, 5);
is $minus_5->(17), 12;

my $complementary_angle = subtract(90);
is $complementary_angle->(30), 60;
is $complementary_angle->(72), 18;

done_testing;
