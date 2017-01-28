use Test::Most;

use Yoda qw(reject);

my $is_odd = sub { $_[0] % 2 == 1 };

eq_or_diff(
    reject($is_odd, [1, 2, 3, 4]),
    [2, 4],
    'reject over ArrayRef',
);

eq_or_diff(
    reject($is_odd, {a => 1, b => 2, c => 3, d => 4}),
    {b => 2, d => 4},
    'reject over HashRef',
);

done_testing;
