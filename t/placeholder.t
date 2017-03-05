use Test::Most;

use Yoda qw(__ divide replace);

my $divide_by_10 = divide(__(), 10);
is $divide_by_10->(1000), 100, 'divide';

my $greet = replace('{name}', __, 'Hello, {name}!');
is $greet->('Alice'), 'Hello, Alice!', 'replace';

my $divide = divide(__, __);
my $divide_1000_by = $divide->(1000);

is ref($divide_1000_by), 'CODE', 'partial + placeholder';
is $divide_1000_by->(10), 100, 'complete partial + placeholder';

done_testing;

