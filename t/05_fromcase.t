use strict;
use warnings FATAL => 'all';

use Test::More;
use Test::Exception;

use Pdbc;
use Pdbc::Where;

my $test = bless {
	id => 'INTEGER',
	name => 'TEXT',
	flg => 'BOOLEAN'
}, 'Test';

subtest 'list', sub {
	my $manager = Pdbc::connect('SQLite', 'test.db');
	$manager->drop($test)->execute();
	$manager->create($test)->execute();

	$manager->insert(bless {id => 1, name => 'name_1', flg => 1}, 'Test')->execute();
	$manager->insert(bless {id => 2, name => 'name_2', flg => undef}, 'Test')->execute();

	my $actual = $manager->from($test)->list();
	my $expect = [{id => 1, name => 'name_1', flg => 1}, {id => 2, name => 'name_2', flg => ''}];
	is scalar(@$actual), 2;
	is_deeply $actual->[0], $expect->[0];
	is_deeply $actual->[1], $expect->[1];

	dies_ok sub {
		$manager->from($test)->where(Pdbc::Where->new('id', {}, EQUAL))->list();
	}, 'should die.';

	my $not_exist = bless {
		id => 'INTEGER'
	}, 'NotExist';

	dies_ok sub {
		$manager->from($not_exist)->list();
	}, 'should die.';
};

subtest 'single_result', sub {
	my $manager = Pdbc::connect('SQLite', 'test.db');
	$manager->drop($test)->execute();
	$manager->create($test)->execute();

	$manager->insert(bless {id => 1, name => 'name_1', flg => 1}, 'Test')->execute();
	$manager->insert(bless {id => 2, name => 'name_2', flg => undef}, 'Test')->execute();

	my $actual = $manager->from($test)->where(Pdbc::Where->new('id', 1, EQUAL))->single_result();
	my $expect = {id => 1, name => 'name_1', flg => 1};
	is_deeply$actual, $expect;

	dies_ok sub {
		$manager->from($test)->where(Pdbc::Where->new('id', {}, EQUAL))->single_result();
	}, 'should die.';

	dies_ok sub {
		$manager->from($test)->single_result();
	}, 'should die.';
};

subtest 'delete', sub {
	my $manager = Pdbc::connect('SQLite', 'test.db');
	$manager->drop($test)->execute();
	$manager->create($test)->execute();

	$manager->insert(bless {id => 1, name => 'name_1', flg => 1}, 'Test')->execute();
	$manager->insert(bless {id => 2, name => 'name_2', flg => undef}, 'Test')->execute();

	$manager->from($test)->where(Pdbc::Where->new('id', 1, EQUAL))->delete()->execute();
	my $actual = $manager->from($test)->single_result();
	my $expect = {id => 2, name => 'name_2', flg => ''};
	is_deeply $actual, $expect;
};

done_testing();