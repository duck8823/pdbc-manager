use strict;
use warnings FATAL => 'all';

use Test::More;
use Test::Exception;

use Pdbc;
use v5.19;


subtest 'readme', sub {
	my $manager = Pdbc::connect("Pg", "dbname=test;host=localhost", "postgres");

	BEGIN {
		struct 'Hoge', ['id', 'name', 'flg'];
	}
	$manager->drop(Hoge)->execute();
	$manager->create(Hoge->new('INTEGER', 'TEXT', 'BOOLEAN'))->execute();

	$manager->insert(Hoge->new(1, 'name_1', 1))->execute();
	$manager->insert(Hoge->new(2, 'name_2', 'false'))->execute();
	$manager->insert(Hoge->new(3, 'name_3', 0))->execute();

	my $actual = $manager->from(Hoge)->list();
	my $expect = [{id => 1, name => 'name_1', flg => 1}, {id => 2, name => 'name_2', flg => 0}, {id => 3, name => 'name_3', flg => 0}];

	is_deeply $actual, $expect;
};

done_testing();