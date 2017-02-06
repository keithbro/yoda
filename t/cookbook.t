use Test::Most;

use Yoda qw(compose identity pick_all unapply values);

my $pick_indexes = compose(values(), pick_all());
eq_or_diff(
    $pick_indexes->([0, 2], ['a', 'b', 'c']),
    ['a', 'c'],
    'pick values from a list by indexes',
);

my $list = unapply(identity());
eq_or_diff($list->(1, 2, 3), [1, 2, 3], 'create a list function');

done_testing;
