use Test::Most;

use Yoda qw(always equals identity if_else);

my $pronunce_syllable = if_else(
    equals('ewe'),
    always('yo'),
    identity(),
);

is $pronunce_syllable->('ewe'), 'yo', 'on_true';
is $pronunce_syllable->('no'), 'no', 'on_false';

done_testing;

