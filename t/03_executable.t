use strict;
use warnings FATAL => 'all';

use Test::More;
use Test::Exception;

use Pdbc;


subtest 'execute', sub {
	my $manager = Pdbc::connect('SQLite', 'test.db');

	BEGIN {
		struct 'Fail', ['id', 'fail'];
	}

	dies_ok sub {
		$manager->create(Fail)->execute();
	}, 'should die.';

	BEGIN {
		struct 'Success', ['id', 'name'];
	}

	$manager->drop(Success)->execute();
	$manager->create(Success->new('INTEGER', 'TEXT'))->execute();

	dies_ok sub {
		$manager->create(Success->new('INTEGER', 'TEXT'))->execute();
	}, 'should die.';
};

subtest 'get_sql', sub {
	my $manager = Pdbc::connect('SQLite', 'test.db');

	BEGIN {
		struct 'Hoge', ['id', 'name'];
	}

	my $actual = $manager->create(Hoge->new('INTEGER', 'TEXT'))->get_sql();
	my $expect = "CREATE TABLE Hoge (id INTEGER, name TEXT)";
	is $actual, $expect;
};

done_testing();

