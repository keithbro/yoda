use Test::Most;

use Yoda qw(append flip);

eq_or_diff(
    flip(append())->([], 1),
    [1],
    'flip append',
);

my $merge_three = sub {
    my ($x, $y, $z) = @_;
    [ $x, $y, $z ];
};

eq_or_diff $merge_three->(1, 2, 3), [1, 2, 3], 'merge three';
eq_or_diff flip($merge_three)->(1, 2, 3), [2, 1, 3], 'flipped merge three';

my $put_in_array = flip(append())->([]);

eq_or_diff $put_in_array->(5), [5], 'partial application';
eq_or_diff $put_in_array->(9), [9], 'partial application';

done_testing;
