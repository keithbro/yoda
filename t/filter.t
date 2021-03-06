use Test::Most;

use Yoda qw(append filter flip);

my $is_even = sub { shift() % 2 == 0 };

eq_or_diff(
    filter( $is_even, [ 1, 2, 3, 4 ] ),
    [ 2, 4 ],
    'filter an array',
);

eq_or_diff(
    filter( $is_even, { a => 1, b => 2, c => 3, d => 4 } ),
    { b => 2, d => 4 },
    'filter a HashRef',
);

my $reducer = filter($is_even, flip(append()));
eq_or_diff $reducer->([], 1), [], 'reducer - append';
eq_or_diff $reducer->([], 2), [2], 'reducer - do not append';

done_testing;
