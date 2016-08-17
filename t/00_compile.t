use strict;
use warnings FATAL => 'all';

use Test::More;

local $SIG{__WARN__} = sub { fail shift };

use_ok $_ for qw(
	Pdbc
	Pdbc::Manager
	Pdbc::Executable
	Pdbc::FromCase
	Pdbc::Where
);

done_testing();