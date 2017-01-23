use Test::Most;

use Yoda qw(group_by);

my $by_grade = group_by(
    sub {
        my ($student) = @_;
        my $score = $student->{score};
        return $score < 65 ? 'F' :
               $score < 70 ? 'D' :
               $score < 80 ? 'C' :
               $score < 90 ? 'B' : 'A';
    }
);

my $students = [
    {name => 'Abby', score => 84},
    {name => 'Eddy', score => 58},
    {name => 'Jack', score => 69},
];

eq_or_diff(
    $by_grade->($students),
    {
        'B' => [{name => 'Abby', score => 84}],
        'D' => [{name => 'Jack', score => 69}],
        'F' => [{name => 'Eddy', score => 58}],
    },
);

done_testing;
