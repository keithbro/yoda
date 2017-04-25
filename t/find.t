use Test::Most;

use Yoda qw(find prop_eq);

subtest arrayref => sub {
    my $xs = [{a => 1}, {a => 2}, {a => 3}];

    eq_or_diff(
        find(prop_eq('a', 2))->($xs),
        {a => 2},
    );

    eq_or_diff(
        find(prop_eq('a', 4))->($xs),
        undef,
    );
};

subtest blessed => sub {
    my $set = Set->new();
    my $predicate = prop_eq(a => 2);

    eq_or_diff(
        find($predicate, $set),
        { a => 2 },
        'dispatched to find method of $set',
    );
};

done_testing;

{
    package Set;

    use List::Util qw();

    sub new {
        return bless {
            things => [ { a => 1 }, { a => 2 }, { a => 4 } ],
        }, shift;
    }

    sub find {
        my $self = shift;
        my ($predicate) = @_;

        return List::Util::first { $predicate->($_) } @{$self->{things}};
    }

    1;
}

