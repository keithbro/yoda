use Test::Most;

use Yoda qw(where_eq);

my $pred = where_eq({ a => 1, b => 2 });

ok !$pred->({ a => 1                     });
ok  $pred->({ a => 1  , b => 2  ,        });
ok  $pred->({ a => 1  , b => 2  , c => 3 });
ok !$pred->({ a => 1  , b => 1  ,        });
ok !$pred->({ a => '1', b => '2',        });

done_testing;
