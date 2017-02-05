use Test::Most;

use Yoda qw(append flip);

eq_or_diff(
    flip(append())->([], 1),
    [1],
    'flip append',
);

done_testing;
