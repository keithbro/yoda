use Test::Most;

use Yoda qw(juxt max min);

my $get_range = juxt( [ min(), max() ] );

eq_or_diff($get_range->(3, 4, 9, -3), [-3, 9], 'juxt min max');

done_testing;
