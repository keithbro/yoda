use Test::Most;

use Yoda qw(compose if_else equals always identity);

my $pronunce_syllable = if_else(equals('ewe'), always('yo'), identity());
my $pronunce_syllables = compose(Yoda::join(''), Yoda::map($pronunce_syllable));

eq_or_diff $pronunce_syllables->(['ewe', 'da']), 'yoda', 'ewe + da = yoda';

done_testing;
