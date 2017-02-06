use Test::Most;

use List::Util qw();

use Yoda qw(apply);

my $numbers = [1, 2, 3, -99, 42, 6, 7];
is apply(\&List::Util::max, $numbers), 42;

done_testing;
