use Test::Most;

use Yoda qw(append flip reduced take);

eq_or_diff take(1, ['foo', 'bar', 'baz']), ['foo'];
eq_or_diff take(2, ['foo', 'bar', 'baz']), ['foo', 'bar'];
eq_or_diff take(3, ['foo', 'bar', 'baz']), ['foo', 'bar', 'baz'];
eq_or_diff take(4, ['foo', 'bar', 'baz']), ['foo', 'bar', 'baz'];
eq_or_diff take(3, ['foo', undef, 'baz']), ['foo', undef, 'baz'];
eq_or_diff take(3, 'ramda'),             , 'ram';

my $personnel = [
    'Dave Brubeck',
    'Paul Desmond',
    'Eugene Wright',
    'Joe Morello',
    'Gerry Mulligan',
    'Bob Bates',
    'Joe Dodge',
    'Ron Crotty'
];

my $take_five = take(5);
eq_or_diff(
    $take_five->($personnel),
    [
        'Dave Brubeck',
        'Paul Desmond',
        'Eugene Wright',
        'Joe Morello',
        'Gerry Mulligan',
    ],
);

my $reducer = take(2, flip(append()));

eq_or_diff($reducer->([], 1), [1], 'reducer - not last');

my $final = $reducer->([1], 2);
is ref($final), 'Yoda::Reduced', 'reducer - last - ref';
eq_or_diff($final->{value}, [1, 2], 'reducer - last - value');

throws_ok(
    sub { $reducer->([1, 2], 3) },
    qr/Died/,
    'die when limit exceeded',
);

done_testing;
