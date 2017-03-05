use Test::Most;

use Yoda qw(any flip lt);

my $less_than_0 = flip(lt())->(0);
my $less_than_2 = flip(lt())->(2);

ok !any($less_than_0)->([1, 2]), '1 !< 0 && 2 !< 0';
ok any($less_than_2)->([1, 2]), '1 < 2 || 2 !< 2';

done_testing;
