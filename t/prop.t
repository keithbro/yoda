use Test::Most;

use Yoda qw(prop);

subtest 'HashRef' => sub {
    my $hashref = {
        a => 1,
    };

    is prop('a', $hashref), 1, 'found => value';
    is prop('b', $hashref), undef, 'not found => undef';
};

subtest 'errors' => sub {
    throws_ok(
       sub { prop('c', undef) },
       qr/second argument must be a HashRef or blessed/,
    );

    throws_ok(
       sub { prop('c', []) },
       qr/second argument must be a HashRef or blessed/,
    );

    throws_ok(
       sub { prop('c', 1) },
       qr/second argument must be a HashRef or blessed/,
    );
};

subtest 'blessed_object' => sub {
    {
        package Animal;

        sub new { bless {}, shift }

        sub name { $_[1] ? $_[0]->{_name} = $_[1] : $_[0]->{_name} }

        1;
    }

    my $animal = Animal->new();
    $animal->name('Brian');

    is $animal->name, 'Brian', 'sanity check #1';
    is $animal->{name}, undef, 'sanity check #2';
    is $animal->{_name}, 'Brian', 'sanity check #3';
    is prop('name', $animal), 'Brian', 'blessed';
};

done_testing;
