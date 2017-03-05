use Test::Most;

use Yoda qw(lt);

ok !lt(2, 1);
ok !lt(2, 2);
ok lt(2, 3);

done_testing;
