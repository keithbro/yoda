use Test::Most;

use Yoda qw(add compose memoize multiply product range to_upper);

my $abs = sub { abs(shift()) };

my $classy_greeting = sub {
    sprintf("The name's %s, %s %s.", $_[1], $_[0], $_[1]);
};

my $yell_greeting = compose(to_upper, $classy_greeting);

is(
    $yell_greeting->('James', 'Bond'),
    "THE NAME'S BOND, JAMES BOND.",
    'compose two functions',
);

is(
    compose($abs, add(1), multiply(2))->(-4), 7,
    'compose three functions',
);

my $factorial = memoize(compose(product(), range(1)));

is $factorial->(5), 120, 'memoize(compose(product, range(1))';

done_testing;
