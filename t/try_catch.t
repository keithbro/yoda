use Test::Most;

use Yoda qw(F prop try_catch);

is try_catch(prop('x'), F())->({x => 2}), 2, 'tryer';
is try_catch(prop('x'), F())->(undef), '', 'catcher';

done_testing;
