use strict;
use warnings FATAL => 'all';

use Test::More;
use Test::Exception;

use 5.019;

use Pdbc;
use Pdbc::Where;

BEGIN {
	struct 'Test', ['id', 'name'];
}

subtest 'connection', sub {
	my $manager = Pdbc::connect('SQLite', 'test.db');
	isa_ok $manager, 'Pdbc::Manager';
};

subtest 'create', sub {
	my $manager = Pdbc::connect('SQLite', 'test.db');
	$manager->drop(Test)->execute();
	$manager->create(Test->new('INTEGER', 'TEXT'))->execute();

	my $sth = $manager->{_db}->prepare('PRAGMA TABLE_INFO(Test)');
	$sth->execute();

	my $table_info;
	my $rows = $sth->fetchall_arrayref(+{name => 1, type => 1});
	while (my $row = shift @$rows) {
		$table_info->{$row->{name}} = $row->{type};
	}
	is_deeply $table_info, {id => 'INTEGER', name => 'TEXT'};
};

subtest 'drop', sub {
	my $manager = Pdbc::connect('SQLite', 'test.db');
	$manager->drop(Test)->execute();
	$manager->create(Test->new('INTEGER', 'TEXT'))->execute();

	$manager->drop(Test)->execute();

	my $sth = $manager->{_db}->prepare('PRAGMA TABLE_INFO(Test)');
	$sth->execute();
	my $rows = $sth->fetchall_arrayref();
	is scalar(@$rows), 0, 'should not exist table.';
};

subtest 'insert', sub {
	my $manager = Pdbc::connect('SQLite', 'test.db');
	$manager->drop(Test)->execute();
	$manager->create(Test->new('INTEGER', 'TEXT'))->execute();

	$manager->insert(Test->new(1, 'name_1'))->execute();
	$manager->insert(Test->new(2, 'name_2'))->execute();
	$manager->insert(Test->new(3, undef))->execute();

	my $expect = [{id => 1, name => 'name_1'}, {id => 2, name => 'name_2'}, {id => 3, name => undef}];
	my $sth = $manager->{_db}->prepare('SELECT * FROM Test');
	$sth->execute();
	my $actual = $sth->fetchall_arrayref(+{});
	is_deeply $actual, $expect;
};

subtest 'update', sub {
	my $manager = Pdbc::connect('SQLite', 'test.db');
	$manager->drop(Test)->execute();
	$manager->create(Test->new('INTEGER', 'TEXT'))->execute();

	$manager->insert(Test->new(1, 'name_1'))->execute();
	$manager->insert(Test->new(2, 'name_2'))->execute();
	$manager->update(Test->new(3, 'name_3'))->where(Pdbc::Where->new('id', 1, EQUAL))->execute();

	my $expect = [{id => 3, name => 'name_3'}, {id => 2, name => 'name_2'}];
	my $sth = $manager->{_db}->prepare('SELECT * FROM Test');
	$sth->execute();
	my $actual = $sth->fetchall_arrayref(+{});
	is_deeply $actual, $expect;
};

subtest 'create_insert_clause', sub {
	my $actual = Pdbc::Manager::_create_insert_clause(Test->new(1, 'name_1'));
	is $actual, "(id, name) VALUES ('1', 'name_1')";

	$actual = Pdbc::Manager::_create_insert_clause(Test->new(2, undef));
	is $actual, "(id, name) VALUES ('2', NULL)";

	$actual = Pdbc::Manager::_create_insert_clause(Test->new(3, "ho'ge"));
	is $actual, "(id, name) VALUES ('3', 'ho''ge')";
};

done_testing();

