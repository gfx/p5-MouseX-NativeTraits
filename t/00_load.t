#!perl -w

use strict;
use Test::More;

require_ok 'MouseX::NativeTraits';
require_ok 'MouseX::NativeTraits::MethodProvider';

foreach my $type(qw(ArrayRef HashRef CodeRef Str Num Bool Counter)){
    my $trait = 'MouseX::NativeTraits::' . $type;

    require_ok $trait;
    require_ok $trait->method_provider_class;
}


diag "Testing MouseX::NativeTraits/$MouseX::NativeTraits::VERSION";


done_testing;
