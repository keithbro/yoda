use Test::Most;

use Yoda qw(__ divide replace);

my $divide_by_10 = divide(__(), 10);
is $divide_by_10->(100), 10, 'divide';

my $greet = replace('{name}', __, 'Hello, {name}!');
is $greet->('Alice'), 'Hello, Alice!', 'replace';

done_testing;

