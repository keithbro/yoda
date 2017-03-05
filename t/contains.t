use Test::Most;

use Yoda qw(contains);

ok contains(3, [1, 2, 3]);
ok !contains(4, [1, 2, 3]);
ok !contains('3', [1, 2, 3]);
ok contains({ name => 'Fred' }, [{ name => 'Fred' }]);
ok contains([42], [[42]]);
ok contains('a', 'bars'), 'string does contain';
ok !contains('c', 'bars'), 'string does not contain';

done_testing;
