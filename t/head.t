use Test::Most;

use Yoda qw(head);

eq_or_diff(head(['fi', 'fo', 'fum']), 'fi', 'head of array');
is head([]), undef, '[] => undef';
is head(''), '', "'' => ''";
eq_or_diff(head('abc'), 'a', 'head of string');

done_testing;
