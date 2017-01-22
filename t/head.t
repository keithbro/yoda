use Test::Most;

use Yoda;

eq_or_diff(
    Yoda::head(['fi', 'fo', 'fum']),
    'fi',
    'head of array',
);

eq_or_diff(
    Yoda::head('abc'),
    'a',
    'head of string',
);

done_testing;
