use Test::Most;

use Yoda qw(filter);

my $isEven = sub { shift() % 2 == 0 };

eq_or_diff(
    filter( $isEven, [ 1, 2, 3, 4 ] ),
    [ 2, 4 ],
    'filter an array',
);

eq_or_diff(
    filter( $isEven, { a => 1, b => 2, c => 3, d => 4 } ),
    { b => 2, d => 4 },
    'filter a HashRef',
);

done_testing;
