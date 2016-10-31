use strict;
use warnings FATAL => 'all';

use Test::More;
use Test::Exception;

use Pdbc;

BEGIN {
	struct 'Test', ['id', 'name'];
}

subtest 'abort', sub {
	my $manager = Pdbc::connect('SQLite', 'test.db');
	$manager->drop(Test)->execute;

	my $sth = $manager->{_db}->prepare('PRAGMA TABLE_INFO(Test)');
	$sth->execute();
	my $rows = $sth->fetchall_arrayref();
	is scalar(@$rows), 0, 'should not exist table.';

	$manager->begin;
	$manager->create(Test->new('INTEGER', 'TEXT'))->execute;

	$manager->{_db}->disconnect;

	$manager = Pdbc::connect('SQLite', 'test.db');
	$sth = $manager->{_db}->prepare('PRAGMA TABLE_INFO(Test)');
	$sth->execute();
	$rows = $sth->fetchall_arrayref();
	is scalar(@$rows), 0, 'should not exist table.';
};

subtest 'commit', sub {
	my $manager = Pdbc::connect('SQLite', 'test.db');
	$manager->drop(Test)->execute;

	my $sth = $manager->{_db}->prepare('PRAGMA TABLE_INFO(Test)');
	$sth->execute();
	my $rows = $sth->fetchall_arrayref();
	is scalar(@$rows), 0, 'should not exist table.';

	$manager->begin;
	$manager->create(Test->new('INTEGER', 'TEXT'))->execute;

	$manager->commit;

	$sth = $manager->{_db}->prepare('PRAGMA TABLE_INFO(Test)');
	$sth->execute();

	my $table_info;
	$rows = $sth->fetchall_arrayref(+{name => 1, type => 1});
	while (my $row = shift @$rows) {
		$table_info->{$row->{name}} = $row->{type};
	}
	is_deeply $table_info, {id => 'INTEGER', name => 'TEXT'};
};

subtest 'rollback', sub {
	my $manager = Pdbc::connect('SQLite', 'test.db');
	$manager->drop(Test)->execute;

	my $sth = $manager->{_db}->prepare('PRAGMA TABLE_INFO(Test)');
	$sth->execute();
	my $rows = $sth->fetchall_arrayref();
	is scalar(@$rows), 0, 'should not exist table.';

	$manager->begin;
	$manager->create(Test->new('INTEGER', 'TEXT'))->execute;

	$manager->rollback;

	$sth = $manager->{_db}->prepare('PRAGMA TABLE_INFO(Test)');
	$sth->execute();
	$rows = $sth->fetchall_arrayref();
	is scalar(@$rows), 0, 'should not exist table.';
};

done_testing();