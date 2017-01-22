use Test::Most;

use Yoda;

my $count = 0;

my $factorial = Yoda::memoize(sub {
    my ($n) = @_;
    $count++;
    return Yoda::product(Yoda::range(1, $n));
});

is $factorial->(5), 120, 'first call';
is $factorial->(5), 120, 'second call';
is $count, 1, 'second call used memoize';

my $test = Yoda::memoize(Yoda::always('hello'));

is $test->(5), 'hello', 'memoized per function';

done_testing;
