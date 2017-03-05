use Test::Most;

use Yoda qw(equals);

ok equals(1, 1), 'numbers are equal';
ok !equals(1, 2), 'numbers are not equal';

ok equals([1,2,3], [1,2,3]), 'array are equal';
ok !equals([1,2,3], [1,4,3]), 'arrays are not equal';

ok equals('hello', 'hello'), 'strings are equal';
ok !equals('hello', 'world'), 'strings are not equal';

ok !equals(1, '1'), 'number 1 not equal to string 1';

done_testing;
