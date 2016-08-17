use strict;
use warnings FATAL => 'all';

use Test::More;
use Test::Exception;

use Pdbc;

subtest 'new', sub {
	my $manager = Pdbc::connect('SQLite', 'test.db');
	isa_ok $manager, 'Pdbc::Manager';

	dies_ok {
		Pdbc::connect();
	};
	dies_ok {
		Pdbc::connect('SQLite', 'test.db', 'extra');
	};
};

done_testing();