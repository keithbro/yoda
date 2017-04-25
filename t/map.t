use Test::Most;

use Yoda qw(compose);

my $double = sub { shift() * 2 };
my $map_double = Yoda::map($double);
my $composed_maps = compose($map_double, $map_double);

eq_or_diff(
    $map_double->([1, 2, 3]),
    [2, 4, 6],
    'map over ArrayRef',
);

eq_or_diff(
    $map_double->({x => 1, y => 2, z => 3}),
    {x => 2, y => 4, z => 6},
    'map over HashRef',
);

eq_or_diff(
    $composed_maps->({ x => 1, y => 2, z => 3}),
    { x => 4, y => 8, z => 12 },
    'composed maps',
);

is Yoda::map($double, MyNumber->new(7)), 14, 'dispatched to map method';

throws_ok(
    sub { Yoda::map($double, 42) },
    qr/second argument must be a HashRef, ArrayRef, CodeRef or blessed/,
    'attempt to map over an Int throws exception',
);

done_testing;

{
    package MyNumber;

    sub new {
        my ($class, $value) = @_;
        bless { value => $value }, $class;
    }

    sub map {
        my $self = shift;
        my ($function) = @_;

        $function->($self->{value});
    }

    1;
}

