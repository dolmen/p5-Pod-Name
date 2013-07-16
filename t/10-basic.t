use strict;
use warnings;

use Test::More 0.98 tests => 2;
use Test::NoWarnings;

use Pod::Name;

open my $f, '<', File::Spec->catfile(qw<lib Pod Name.pm>);
is(Pod::Name->extract_name($f), 'Pod::Name - Extract the NAME section of a POD document', 'lib/Pod/Name.pm');

