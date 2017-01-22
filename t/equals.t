use Test::Most;

use Yoda;

is Yoda::equals(1, 1), 1, 'equals number';
is Yoda::equals(1, '1'), 1, 'equals different type (differs from Ramda)';
is Yoda::equals([1,2,3], [1,2,3]), 1, 'equals array';

done_testing;
