use Test::Most;

use Yoda qw(unfold);

my $f = sub { my ($n) = @_; $n > 50 ? '' : [-$n, $n + 10] };

eq_or_diff unfold($f, 10), [-10, -20, -30, -40, -50];

done_testing;
