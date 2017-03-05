use Test::Most;

use Yoda qw(lt);

ok !lt(2, 1), '2 is not less than 1';
ok !lt(2, 2), '2 is not less than 2';
ok lt(2, 3), '2 is less than 3';
ok lt('a', 'z'), 'a is less than z';
ok !lt('z', 'a'), 'z is not less than a';
ok lt(5, '^'), '5 is less than ^';

done_testing;
