use Test::Most;

use Yoda qw(contains partition);

eq_or_diff(
    partition(contains('s'), ['sss', 'ttt', 'foo', 'bars']),
    [ [ 'sss', 'bars' ],  [ 'ttt', 'foo' ] ],
    'partition over arrayref',
);

eq_or_diff(
    partition(contains('s'), { a => 'sss', b => 'ttt', foo => 'bars' }),
    [ { a => 'sss', foo => 'bars' }, { b => 'ttt' } ],
    'partition over hashref',
);

done_testing;
