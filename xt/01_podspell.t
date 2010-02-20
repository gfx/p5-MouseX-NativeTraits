#!perl -w

use strict;
use Test::More;

eval q{ use Test::Spelling };

plan skip_all => q{Test::Spelling is not installed.}
	if $@;

add_stopwords(map { split /[\s\:\-]/ } <DATA>);
$ENV{LANG} = 'C';
all_pod_files_spelling_ok('lib');

__DATA__
Goro Fuji (gfx)
gfuji(at)cpan.org
MouseX::NativeTraits

Stevan
clearers
cpan
extention
gfx
Num
Str
versa
uniq
indices
dec
kv
isa
arity
metaclass
attr
