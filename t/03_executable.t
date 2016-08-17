use strict;
use warnings FATAL => 'all';

use Test::More;
use Test::Exception;

use Pdbc;


subtest 'execute', sub {
	my $manager = Pdbc::connect('SQLite', 'test.db');

	my $fail = bless { id => 'INTEGER', fail => 'FAIL_TYPE' }, 'Fail';

	dies_ok sub {
		$manager->create($fail)->execute();
	}, 'should die.';

	my $success = bless { id => 'INTEGER', name => 'TEXT' }, 'Success';

	$manager->drop($success)->execute();
	$manager->create($success)->execute();

	dies_ok sub {
		$manager->create($success)->execute();
	}, 'should die.';
};

subtest 'get_sql', sub {
	my $manager = Pdbc::connect('SQLite', 'test.db');

	my $hoge = bless {id => 'INTEGER', name => 'TEXT'}, 'Hoge';

	my $actual = $manager->create($hoge)->get_sql();
	my $expect = "CREATE TABLE Hoge ('id' INTEGER, 'name' TEXT)";
	is $actual, $expect;
};

done_testing();

