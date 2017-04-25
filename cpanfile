requires 'perl', '5.008001';
requires 'autobox';
requires 'JSON';
requires 'Try::Tiny';

on 'test' => sub {
    requires 'Test::Most';
};

