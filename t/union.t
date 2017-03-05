use Test::Most;

use Yoda qw(contains union);

my $union = union([1, 2, 3], [2, 3, 4, '2']);

is scalar @$union, 5, 'five elements in union';
ok contains(2, $union), 'found numeric 2';
ok contains('2', $union), 'found string 2';
ok contains(3, $union), 'found numeric 3 - sanity';
ok !contains('3', $union), 'no string 3 - sanity';

cmp_bag(
    $union,
    [1, 2, 3, 4, '2'],
    'union numbers',
);

done_testing;
