use Test::Most;

use Yoda qw(type);

my %example_for_type = (
    Hash            => {},
    Integer         => 1,
    Float           => 1.0,
    String          => '1',
    Undef           => undef,
    Array           => [],
    Regexp          => qr/[A-z]/,
    Code            => type(),
    'Animal::Dog'   => bless({}, 'Animal::Dog'),
);

for my $type (keys %example_for_type) {
    is type($example_for_type{$type}), $type, "identify a $type";
}

done_testing;
