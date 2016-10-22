use strict;
use warnings FATAL => 'all';

use Test::More;
use Test::Exception;

use Pdbc;

BEGIN {
	struct 'Test', ['id', 'name'];
}

subtest 'list', sub {
	my $manager = Pdbc::connect('SQLite', 'test.db');
	$manager->drop(Test)->execute();
	$manager->create(Test->new('INTEGER', 'TEXT'))->execute();

	$manager->insert(Test->new(1, 'name_1'))->execute();
	$manager->insert(Test->new(2, 'name_2'))->execute();

	my $actual = $manager->from(Test)->list();
	my $expect = [{id => 1, name => 'name_1'}, {id => 2, name => 'name_2'}];
	is scalar(@$actual), 2;
	is_deeply $actual->[0], $expect->[0];
	is_deeply $actual->[1], $expect->[1];

	my $not_exist = bless {
		id => 'INTEGER'
	}, 'NotExist';

	dies_ok sub {
		$manager->from($not_exist)->list();
	}, 'should die.';
};

subtest 'single_result', sub {
	my $manager = Pdbc::connect('SQLite', 'test.db');
	$manager->drop(Test)->execute();
	$manager->create(Test->new('INTEGER', 'TEXT'))->execute();

	$manager->insert(Test->new(1, 'name_1'))->execute();
	$manager->insert(Test->new(2, 'name_2'))->execute();

	my $actual = $manager->from(Test)->where(Pdbc::Where->new('id', 1, EQUAL))->single_result();
	my $expect = {id => 1, name => 'name_1'};
	is_deeply$actual, $expect;

	dies_ok sub {
		$manager->from(Test)->where(Pdbc::Where->new('id', {}, EQUAL))->single_result();
	}, 'should die.';

	dies_ok sub {
		$manager->from(Test)->single_result();
	}, 'should die.';
};

subtest 'delete', sub {
	my $manager = Pdbc::connect('SQLite', 'test.db');
	$manager->drop(Test)->execute();
	$manager->create(Test->new('INTEGER', 'TEXT'))->execute();

	$manager->insert(Test->new(1, 'name_1'))->execute();
	$manager->insert(Test->new(2, 'name_2'))->execute();

	$manager->from(Test)->where(Pdbc::Where->new('id', 1, EQUAL))->delete()->execute();
	my $actual = $manager->from(Test)->single_result();
	my $expect = {id => 2, name => 'name_2'};
	is_deeply $actual, $expect;
};

done_testing();