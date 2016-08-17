# PdbcManager
[![Build Status](https://travis-ci.org/duck8823/pdbc-manager.svg?branch=master)](https://travis-ci.org/duck8823/pdbc-manager)
[![Coverage Status](http://coveralls.io/repos/github/duck8823/pdbc-manager/badge.svg?branch=master)](https://coveralls.io/github/duck8823/pdbc-manager?branch=master)
[![MIT License](http://img.shields.io/badge/license-MIT-blue.svg?style=flat)](LICENSE)  
  
blessしたハッシュリファレンスでデータベースを操作する  
  
## INSTALL
```sh
git clone https://github.com/duck8823/pdbc-manager.git
cd pdbc-manager
cpan .
```
  
## SYNOPSIS
```perl
use 5.019;

use Data::Dumper;

use Pdbc;

# ハッシュリファレンスをbless
my $entity = bless {
	id => 'INTEGER',
	name => 'TEXT',
	flg => 'BOOLEAN'
}, 'Hoge';

# データベースへの接続
my $manager = Pdbc::connect('SQLite', 'test.db');
# テーブルの作成
$manager->create($entity)->execute();
# データの挿入
$manager->insert(bless {id => 1, name => 'name_1', flg => 1}, 'Hoge')->execute();
$manager->insert(bless {id => 2, name => 'name_2', flg => undef}, 'Hoge')->execute();
# データの取得（リスト）
my $rows = $manager->from($entity)->list();
for my $row (@$rows) {
	say Dumper $row;
}
$manager->from($entity)->where(Pdbc::Where->new('name', 'name', LIKE))->list();
# データの取得（一意）
my $row = $manager->from($entity)->where(Pdbc::Where->new('id', 1, EQUAL))->single_result();
say Dumper $row;
# データの削除
$manager->from($entity)->where(Pdbc::Where->new('id', 1, EQUAL))->delete()->execute();
# テーブルの削除
$manager->drop($entity)->execute();
# SQLの取得
my $create_sql = $manager->create($entity)->get_sql();
my $insert_sql = $manager->insert(bless {id => 1, name => 'name_1', flg => 1}, 'Hoge')->get_sql();
my $delete_sql = $manager->from($entity)->where(Pdbc::Where->new('id', 1, EQUAL))->delete()->get_sql();
my $drop_sql   = $manager->drop($entity)->get_sql();
```

## License
MIT License