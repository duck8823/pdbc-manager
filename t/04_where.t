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

subtest 'to_clause', sub {
	my $actual = Pdbc::Where->new('name', 'name', LIKE)->to_clause();
	is $actual, "WHERE name LIKE '%name%'";

	$actual = Pdbc::Where->new('name', IS_NULL)->to_clause();
	is $actual, 'WHERE name IS NULL';
};

done_testing();

