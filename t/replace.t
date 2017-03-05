use Test::Most;

use Yoda qw(equals replace);

is(
    replace('foo', 'bar', 'foo foo foo'),
    'bar bar bar',
    'Str -> Str -> Str',
);

is(
    replace(qr/foo/, 'bar', 'foo foo foo'),
    'bar bar bar',
    'Regexp -> Str -> Str',
);

is(
    replace(qr/foo/, [ 'bar' ], 'foo foo foo'),
    'bar foo foo',
    'Replace only one foo with bar',
);

is(
    replace('foo', [ 'bar', 'baz', 'bad' ], 'foo foo foo'),
    'bar baz bad',
    'Replace foos with different words',
);

my $original = [3, 7, 'x', 5, 'x', 'x', 9];
my $replacements = [0, 2];
my $predicate = equals('x');

eq_or_diff(
    replace($predicate, $replacements, $original),
    [ 3, 7, 0, 5, 2, 'x', 9],
    'Func -> ArrayRef -> ArrayRef',
);

eq_or_diff $replacements, [0,2], 'replacements are immutable';

eq_or_diff(
    replace($predicate, 'y', $original),
    [ 3, 7, 'y', 5, 'y', 'y', 9 ],
    'Replace all x with y',
);

done_testing;
