use Test::Most;

use Yoda qw(unapply);

my $join_with_space = Yoda::join(' ');

is unapply($join_with_space)->('hello', 'world'), 'hello world';

done_testing;
