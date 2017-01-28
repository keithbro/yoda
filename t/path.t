use Test::Most;

use Yoda qw(path);

is path(['a', 'b'], {a => {b => 2}}), 2, 'got value';
is path(['a', 'b'], {c => {b => 2}}), undef, 'no value';

my $hashref = {};
is path([1, 2, 3], $hashref), undef;
eq_or_diff $hashref, {}, 'no auto-vivification';

done_testing;
