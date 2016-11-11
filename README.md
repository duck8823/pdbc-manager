# PdbcManager
[![Build Status](https://travis-ci.org/duck8823/pdbc-manager.svg?branch=master)](https://travis-ci.org/duck8823/pdbc-manager)
[![Coverage Status](http://coveralls.io/repos/github/duck8823/pdbc-manager/badge.svg?branch=master)](https://coveralls.io/github/duck8823/pdbc-manager?branch=master)
[![MIT License](http://img.shields.io/badge/license-MIT-blue.svg?style=flat)](LICENSE)  
  
blessしたリファレンスでデータベースを操作する  
  
## INSTALL
```sh
git clone https://github.com/duck8823/pdbc-manager.git
cd pdbc-manager
cpanm .
```
  
## SYNOPSIS
```perl
use 5.019;

use Data::Dumper;

use Pdbc;

# モジュールを動的に生成
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
# データの更新
$row->{flg} = 0;
$manager->update($row)->where( Pdbc::Where->new('id', $row->{id}, EQUAL) )->execute();
# データの削除
$manager->from(Hoge)->where( Pdbc::Where->new( 'id', 1, EQUAL ) )->delete()->execute();
# テーブルの削除
$manager->drop(Hoge)->execute();
# SQLの取得
my $create_sql = $manager->create(Hoge->new('INTEGER', 'TEXT', 'BOOLEAN'))->get_sql();
my $insert_sql = $manager->insert(Hoge->new(1, 'name_1', 1))->get_sql();
my $update_sql = $manager->update(Hoge->new(1, 'name_1', 0))->where( Pdbc::Where->new( 'id', 1, EQUAL ) )->get_sql();
my $delete_sql = $manager->from(Hoge)->where( Pdbc::Where->new( 'id', 1, EQUAL ) )->delete()->get_sql();
my $drop_sql = $manager->drop(Hoge)->get_sql();
```

## USAGE
### struct
Python の namedtuple に似た書き方で、クラスを自動生成します.  
```perl
BEGIN {
    struct 'Hoge', [ 'id, 'name', 'flg' ];
}
```
は、以下のモジュールを自動的に生成します.  
```perl
package Hoge;

use 5.019;
use feature 'signatures';
no warnings 'experimental::signatures';

sub new($pkg, $id, $name, $flg) {
    my $self = {
        id => $id,
        name => $name,
        flg => $flg
    };
    return bless $self, ref($pkg) || $pkg;
}
1;
```
第一引数がパッケージ名（テーブル名）、第二引数がキー（カラム名）一覧となります.  
  
また、該当パッケージにサブルーチンを生成します.  
```perl
sub Test {
	return bless [ 'id', 'name', 'flg' ], 'Hoge';
}
```
from や drop の引数にこのサブルーチンを渡すことで簡潔に記述できます.  
  
  
### Where
条件の組み合わせ
```perl
Pdbc::Where->new('column_1', 'value_1', EQUAL)
    ->and(Pdbc::Where->new('column_2', IS_NULL)
        ->or(Pdbc::Where->new('column_2', 'value_2', LIKE)))
    ->and(Pdbc::Where->new('column_3', 'value_3', EQUAL));
```
上記で生成されるSQL
```sql
WHERE ( column_1 = 'value_1' AND ( column_2 IS NULL OR column_2 LIKE '%value_2%' ) AND column_3 = 'value_3' )
```
  
### Transaction
デフォルトはオートコミットですが、トランザクションを制御することもできます.
#### BEGIN TRANSACTION
```perl
$manager->begin;
```
#### COMMIT
```perl
$manager->commit;
```
#### ROLLBACK
```perl
$manager->rollback;
```

## License
MIT License
