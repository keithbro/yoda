use Test::Most;

use Yoda qw(add compose filter take transduce);

my $append = sub { [ @{$_[0]}, $_[1] ] };
my $is_even = sub { $_[0] % 2 == 0 };
my $numbers = [ 1..10 ];

my $transducer = compose(
    Yoda::map(add(1)),
    filter($is_even),
    take(3),
);

eq_or_diff(
    transduce($transducer, $append, [], $numbers),
    [ 2, 4, 6, 8, 10 ],
);

done_testing;
