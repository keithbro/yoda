use Test::Most;

use Yoda;

my $log = '';
my $warn = sub { $log .= "WARN: $_[0]"; return undef };

my $fn = Yoda::try_catch(
    sub { my ($x) = @_; die 'too big' if $x > 5; return $x; },
    $warn,
);

is $fn->(2), 2, 'tryer';
is $log, '', 'nothing logged';
is $fn->(6), undef, 'catcher';
like $log, qr/WARN: too big/, 'logged warning';

done_testing;
