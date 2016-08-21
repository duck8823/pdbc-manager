use strict;
use warnings FATAL => 'all';

use Test::More;
use Test::Exception;

use 5.019;

use Pdbc;
use Data::Dumper;

subtest 'readme', sub {
	lives_ok {
	my $dummy = Pdbc::connect('Pg', 'dbname=test;host=localhost', "postgres");
	$dummy->drop(bless {}, 'Hoge')->execute();

	# 構造体のようなものを定義
	BEGIN {
		struct 'Hoge', [ 'id', 'name', 'flg' ];
	}

	# データベースへの接続
	my $manager = Pdbc::connect('Pg', 'dbname=test;host=localhost', "postgres");
	# テーブルの作成
	$manager->create(Hoge->new('INTEGER', 'TEXT', 'BOOLEAN'))->execute();
	# データの挿入
	$manager->insert(Hoge->new(1, 'name_1', 1))->execute();
	$manager->insert(Hoge->new(2, 'name_2', 0))->execute();
	# データの取得（リスト）
	my $rows = $manager->from(Hoge)->list();
	for my $row ($rows) {
		say Dumper $row;
	}
	$manager->from(Hoge)->where( Pdbc::Where->new( 'name', 'name', LIKE ) )->list();
	# データの取得（一意）
	my $row = $manager->from(Hoge)->where( Pdbc::Where->new( 'id', 1, EQUAL ) )->single_result();
	say Dumper $row;
	# データの削除
	$manager->from(Hoge)->where( Pdbc::Where->new( 'id', 1, EQUAL ) )->delete()->execute();
	# テーブルの削除
	$manager->drop(Hoge)->execute();
	# SQLの取得
	my $create_sql = $manager->create(Hoge->new('INTEGER', 'TEXT', 'BOOLEAN'))->get_sql();
	my $insert_sql = $manager->insert(Hoge->new(1, 'name_1',1))->get_sql();
	my $delete_sql = $manager->from(Hoge)->where( Pdbc::Where->new( 'id', 1, EQUAL ) )->delete()->get_sql();
	my $drop_sql = $manager->drop(Hoge)->get_sql();

	}, 'should live';
};

done_testing();