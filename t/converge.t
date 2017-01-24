use Test::Most;

use Yoda qw(concat converge divide sum to_lower to_upper);

my $average = converge(divide(), [sum(), Yoda::length()]);
is $average->([1,2,3,4,5,6,7]), 4, 'average';

my $strange_concat = converge(concat(), [to_upper(), to_lower()]);
is $strange_concat->("Yodel"), "YODELyodel", 'strange_concat';

done_testing;
