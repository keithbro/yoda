use Test::Most;

use Yoda qw(prop);

my $hashref = {
    a => 1,
};

is prop('a', $hashref), 1;
is prop('b', $hashref), undef;

throws_ok(
   sub { prop('c', undef) },
   qr/Can't use an undefined value as a HASH reference/,
);

throws_ok(
   sub { prop('c', []) },
   qr/Not a HASH reference/,
);

throws_ok(
   sub { prop('c', 1) },
   qr/Can't use string .+ as a HASH ref/,
);


done_testing;
