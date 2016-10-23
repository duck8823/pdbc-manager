use strict;
use warnings FATAL => 'all';

use Test::More;
use Test::Exception;

use Pdbc::Where;
use Pdbc::Operator;

subtest 'new', sub {
	my $where = Pdbc::Where->new('id', 1, EQUAL);
	isa_ok $where, 'Pdbc::Where';

	my $actual = $where->to_clause();
	my $expect = "WHERE id = '1'";
	is $actual, $expect;
};

subtest 'new', sub {
	my $where = Pdbc::Where->new('id', 1, EQUAL);
	isa_ok $where, 'Pdbc::Where';

	dies_ok sub {
		Pdbc::Where->new('id');
	}, 'should die.';

	dies_ok sub {
		Pdbc::Where->new({}, 'value', EQUAL);
	}, 'should die.';

	dies_ok sub {
		Pdbc::Where->new(undef, undef, EQUAL);
	}, 'should die.';

	dies_ok sub {
		Pdbc::Where->new('id', 1, '=');
	}, 'should die.';
};

subtest 'and', sub {
	my $where = Pdbc::Where->new('id', 1, EQUAL);
	$where->and(Pdbc::Where->new('name', IS_NULL));
	$where->and(Pdbc::Where->new('name', 'name', LIKE));
	is_deeply $where->{and}, ["WHERE name IS NULL", "WHERE name LIKE '%name%'"];

	dies_ok sub {
		$where->and(undef);
	}, 'should die.';

	dies_ok sub {
		$where->and(bless {}, 'Fail');
	}, 'should die.';
};

subtest 'or', sub {
	my $where = Pdbc::Where->new('id', 1, EQUAL);
	$where->or(Pdbc::Where->new('name', IS_NULL));
	$where->or(Pdbc::Where->new('name', 'name', LIKE));
	is_deeply $where->{or}, ["WHERE name IS NULL", "WHERE name LIKE '%name%'"];

	dies_ok sub {
		$where->or(undef);
	}, 'should die.';

	dies_ok sub {
		$where->or(bless {}, 'Fail');
	}, 'should die.';
};

subtest 'to_clause', sub {
	my $actual = Pdbc::Where->new('name', 'name', LIKE)->to_clause();
	is $actual, "WHERE name LIKE '%name%'";

	$actual = Pdbc::Where->new('name', IS_NULL)->to_clause();
	is $actual, 'WHERE name IS NULL';

	my $where = Pdbc::Where->new('name', 'name', LIKE);
	$where->and(Pdbc::Where->new('id', IS_NULL));
	is $where->to_clause, "WHERE ( name LIKE '%name%' AND id IS NULL )";

	$where = Pdbc::Where->new()->and(Pdbc::Where->new('id', IS_NOT_NULL));
	is $where->to_clause, "WHERE ( id IS NOT NULL )";

	$where = Pdbc::Where->new('name', 'name', LIKE);
	$where->or(Pdbc::Where->new('id', IS_NULL));
	is $where->to_clause, "WHERE ( name LIKE '%name%' OR id IS NULL )";

	$where = Pdbc::Where->new()->or(Pdbc::Where->new('id', IS_NOT_NULL));
	is $where->to_clause, "WHERE ( id IS NOT NULL )";

	$where = Pdbc::Where->new('name', 'name', LIKE)
		->or(Pdbc::Where->new('id', IS_NOT_NULL)
			->and(Pdbc::Where->new('flg', IS_NULL)))
		->or(Pdbc::Where->new('id', 1, NOT_EQUAL));

	is $where->to_clause, "WHERE ( name LIKE '%name%' OR ( id IS NOT NULL AND flg IS NULL ) OR id <> '1' )";
};

done_testing();

