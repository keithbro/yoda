use Test::Most;

use Yoda qw(curry_n inc negate pipe);

my $pow = curry_n(2, sub { $_[0] ** $_[1] });

my $f = pipe($pow, negate(), inc());

is $f->(3, 4), -80; # -(3^4) + 1

done_testing();

