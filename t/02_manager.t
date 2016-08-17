use strict;
use warnings FATAL => 'all';

use Test::More;
use Test::Exception;

use 5.019;

use Pdbc;
use Pdbc::Where;

my $test = bless {
	id   => 'INTEGER',
	name => 'TEXT',
	flg  => 'BOOLEAN'
}, 'Test';

subtest 'connection', sub {
	my $manager = Pdbc::connect('SQLite', 'test.db');
	isa_ok $manager, 'Pdbc::Manager';
};

subtest 'create', sub {
	my $manager = Pdbc::connect('SQLite', 'test.db');
	$manager->drop($test)->execute();
	$manager->create($test)->execute();

	my $sth = $manager->{_connection}->prepare('PRAGMA TABLE_INFO(Test)');
	$sth->execute();

	my $table_info;
	my $rows = $sth->fetchall_arrayref(+{name => 1, type => 1});
	while (my $row = shift @$rows) {
		$table_info->{$row->{name}} = $row->{type};
	}
	is_deeply $table_info, {id => 'INTEGER', name => 'TEXT', flg => 'BOOLEAN'};
};

subtest 'drop', sub {
	my $manager = Pdbc::connect('SQLite', 'test.db');
	$manager->drop($test)->execute();
	$manager->create($test)->execute();

	$manager->drop($test)->execute();

	my $sth = $manager->{_connection}->prepare('PRAGMA TABLE_INFO(Test)');
	$sth->execute();
	my $rows = $sth->fetchall_arrayref();
	is scalar(@$rows), 0, 'should not exist table.';
};

subtest 'insert', sub {
	my $manager = Pdbc::connect('SQLite', 'test.db');
	$manager->drop($test)->execute();
	$manager->create($test)->execute();

	$manager->insert(bless {id => 1, name => 'name_1', flg => 1}, 'Test')->execute();
	$manager->insert(bless {id => 2, name => 'name_2', flg => undef}, 'Test')->execute();

	my $expect = [{id => 1, name => 'name_1', flg => 1}, {id => 2, name => 'name_2', flg => ''}];
	my $sth = $manager->{_connection}->prepare('SELECT * FROM Test');
	$sth->execute();
	my $actual = $sth->fetchall_arrayref(+{});
	is_deeply $actual, $expect;
};

subtest 'create_sentence', sub {
	my $actual = Pdbc::Manager::_create_sentence(bless {id => 1, name => 'name_1', flg => 1});
	is $actual, "(flg, id, name) VALUES ('1', '1', 'name_1')";
};

subtest 'readme', sub {
	lives_ok {
	my $dummy = Pdbc::connect('SQLite', 'test.db');
	$dummy->drop( bless { }, 'Hoge' )->execute();

	# ハッシュリファレンスをbless
	my $entity = bless {
			id   => 'INTEGER',
			name => 'TEXT',
			flg  => 'BOOLEAN'
		}, 'Hoge';

	# データベースへの接続
	my $manager = Pdbc::connect('SQLite', 'test.db');
	# テーブルの作成
	$manager->create( $entity )->execute();
	# データの挿入
	$manager->insert( bless { id => 1, name => 'name_1', flg => 1 }, 'Hoge' )->execute();
	$manager->insert( bless { id => 2, name => 'name_2', flg => undef }, 'Hoge' )->execute();
	# データの取得（リスト）
	my $rows = $manager->from( $entity )->list();
	for my $row ($rows) {
		say $row;
	}
	$manager->from( $entity )->where( Pdbc::Where->new( 'name', 'name', LIKE ) )->list();
	# データの取得（一意）
	my $row = $manager->from( $entity )->where( Pdbc::Where->new( 'id', 1, EQUAL ) )->single_result();
	say $row;
	# データの削除
	$manager->from( $entity )->where( Pdbc::Where->new( 'id', 1, EQUAL ) )->delete()->execute();
	# テーブルの削除
	$manager->drop( $entity )->execute();
	# SQLの取得
	my $create_sql = $manager->create( $entity )->get_sql();
	my $insert_sql = $manager->insert( bless { id => 1, name => 'name_1', flg => 1 }, 'Hoge' )->get_sql();
	my $delete_sql = $manager->from( $entity )->where( Pdbc::Where->new( 'id', 1,
			EQUAL ) )->delete()->get_sql();
	my $drop_sql = $manager->drop( $entity )->get_sql();
	}, 'should live';
};

done_testing();

