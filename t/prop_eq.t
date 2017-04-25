use Test::Most;

use Yoda qw(prop_eq);

is prop_eq('a', 2)->({ a => 2 }), 1;
is prop_eq('a', 4)->({ a => 2 }), '';

done_testing;
