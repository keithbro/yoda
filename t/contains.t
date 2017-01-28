use Test::Most;

use Yoda qw(contains);

is contains(3, [1, 2, 3]), 1;
is contains(4, [1, 2, 3]), '';
is contains({ name => 'Fred' }, [{ name => 'Fred' }]), 1;
is contains([42], [[42]]), 1;
is contains('a', 'bars'), 1, 'string does contain';
is contains('c', 'bars'), '', 'string does not contain';

done_testing;
