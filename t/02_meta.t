#!perl -w

use strict;
use Test::More;
use Test::Exception;

use Mouse;

lives_ok {
    has foo => (
        traits  => [qw(Array)],
        default => sub{ [] },
        handles => { mypush0 => 'push' },
    );
} '"is" parameter can be omitted';

#throws_ok {
#    has bar1 => (
#        traits  => [qw(Array)],
#        handles => { mypush1 => 'push' },
#    );
#} qr/default .* is \s+ required/xms;

throws_ok {
    has bar2 => (
        traits  => [qw(Array)],
        default => sub{ [] },
        handles => { push => 'mypush2' },
    );
} qr/\b unsupported \b/xms;

throws_ok {
    has bar3 => (
        traits  => [qw(Array)],
        isa     => 'HashRef',
        default => sub{ [] },
        handles => { mypush3 => 'push' },
    );
} qr/must be a subtype of ArrayRef/;

done_testing;
