use Test::Most;

use Yoda qw(always memoize product range);

my $count = 0;

my $factorial = memoize(sub {
    my ($n) = @_;
    $count++;
    return product(range(1, $n));
});

is $factorial->(5), 120, 'first call';
is $factorial->(5), 120, 'second call';
is $count, 1, 'second call used memoize';

my $test = memoize(always('hello'));

is $test->(5), 'hello', 'memoized per function';

done_testing;
