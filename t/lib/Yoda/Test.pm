package Yoda::Test;

use strict;
use warnings;

sub tasks {
    return [
        {
            id => 1,
            complete => 1,
            due_date => '20171231',
            username => 'keith',
        },
        {
            id => 2,
            complete => '',
            due_date => '20170631',
            username => 'rachel',
        },
        {
            id => 3,
            complete => 1,
            due_date => '20161231',
            username => 'shane',
        },
        {
            id => 4,
            complete => '',
            due_date => '20181231',
            username => 'shane',
        },
    ];
};

1;
