use strict;
use warnings;
use inc::Module::Install;

all_from 'lib/MouseX/NativeTraits.pm';

requires 'Mouse' => 0.74;

test_requires 'Test::More'      => 0.88; # done_testing()
test_requires 'Test::Exception' => 0.29;

tests_recursive 't';

auto_set_repository() if -d '.git';

clean_files qw(
    MouseX-NativeTraits-* *.stackdump
    cover_db
    nytprof
    *.out
);

WriteAll(check_nmake => 0);
