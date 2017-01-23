use Test::Most;

use Yoda qw(equals);

is equals(1, 1), 1, 'equals number';
is equals(1, '1'), '', 'equals different type';
is equals([1,2,3], [1,2,3]), 1, 'equals array';

done_testing;
