use strict;
use warnings FATAL => 'all';

use Test::More;
use Test::Exception;

use Pdbc::Where;

subtest 'new', sub {
	my $where = Pdbc::Where->new('id', 1, EQUAL);
	isa_ok $where, 'Pdbc::Where';

	my $actual = $where->to_string();
	my $expect = "WHERE id = '1'";
	is $actual, $expect;
};

subtest 'to_string', sub {
	my $where;
	$where = Pdbc::Where->new(undef, 1, EQUAL);
	dies_ok sub {
		$where->to_string();
	}, 'should die.';

	$where = Pdbc::Where->new('id', undef, EQUAL);
	dies_ok sub {
		$where->to_string();
	}, 'should die.';

	$where = Pdbc::Where->new(undef, undef, EQUAL);
	dies_ok sub {
		$where->to_string();
	}, 'should die.';

	$where = Pdbc::Where->new('id', {}, EQUAL);
	dies_ok sub {
		$where->to_string();
	}, 'should die.';

	my $actual = Pdbc::Where->new('name', 'name', LIKE)->to_string();
	my $expect = "WHERE name LIKE '%name%'";
	is $actual, $expect;
};

subtest 'Operator', sub {
	is EQUAL, '=';
	is NOT_EQUAL, '<>';
	is LIKE, 'LIKE';
	is_deeply \@Pdbc::Where::EXPORT, ['EQUAL', 'NOT_EQUAL', 'LIKE'];
};

done_testing();

