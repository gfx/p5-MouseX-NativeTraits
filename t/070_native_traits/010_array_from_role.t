#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Exception;

{
    package Foo;
    use Mouse;

    has 'bar' => ( is => 'rw' );

    package Stuffed::Role;
    use Mouse::Role;

    has 'options' => (
        traits => ['Array'],
        is     => 'ro',
        isa    => 'ArrayRef[Foo]',
        default => sub{ [] },
    );

    package Bulkie::Role;
    use Mouse::Role;

    has 'stuff' => (
        traits  => ['Array'],
        is      => 'ro',
        isa     => 'ArrayRef',
        default => sub{ [] },
        handles => {
            get_stuff => 'get',
        }
    );

    package Stuff;
    use Mouse;

    ::lives_ok{ with 'Stuffed::Role';
        } '... this should work correctly';

    ::lives_ok{ with 'Bulkie::Role';
        } '... this should work correctly';
}

done_testing;
