use Test::Most;

use Yoda qw(is_defined);

is is_defined(undef), '', 'undef is not defined';
is is_defined(0)    ,  1, '0 is defined';
is is_defined('')   ,  1, '\'\' is defined';
is is_defined([])   ,  1, '[] is defined';

done_testing;
