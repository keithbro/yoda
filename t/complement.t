use Test::Most;

use Yoda qw(complement is_defined);

my $is_undefined = complement(is_defined());
is $is_undefined->(undef), 1;
is $is_undefined->(7), '';

done_testing;
