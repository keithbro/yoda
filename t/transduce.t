use Test::Most;

use Yoda qw(add append compose filter flip take transduce);

my $is_even = sub { $_[0] % 2 == 0 };
my $numbers = [ 1..100000 ];

my $transducer = compose(
    Yoda::map(add(1)),
    filter($is_even),
    take(3),
);

eq_or_diff(
    $transducer->($numbers),
    [3],
    'composition goes right to left',
);

eq_or_diff(
    transduce($transducer, flip(append()), [], $numbers),
    [ 2, 4, 6 ],
    'transduced numbers left to right',
);

done_testing;
