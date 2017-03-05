use Test::Most;

use Yoda qw(is_empty);

ok !is_empty([1, 2, 3]), 'non-empty Array is not empty';
ok is_empty([]), 'empty Array is empty';

ok is_empty(''), 'empty String is empty';
ok !is_empty('hello'), 'non-empty String is not empty';
ok !is_empty(0), 'zero is not empty';

ok !is_empty(undef), 'undef is not empty';

ok is_empty({}), 'empty Hash is empty';
ok !is_empty({length => 0}), 'non-empty Hash is not empty';

ok !is_empty(bless({}, 'Animal')), 'blessed object is not empty';

done_testing;
