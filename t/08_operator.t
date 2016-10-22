use strict;
use warnings FATAL => 'all';

use Test::More;
use Test::Exception;

use Pdbc::Operator;

subtest 'new', sub {
	my $operator = Pdbc::Operator->__new('hoge', 1);
	isa_ok $operator, 'Pdbc::Operator';
};

subtest 'Operator', sub {
	is EQUAL, '=';
	is NOT_EQUAL, '<>';
	is LIKE, 'LIKE';
	is IS_NULL, 'IS NULL';
	is IS_NOT_NULL, 'IS NOT NULL';
	is_deeply \@Pdbc::Operator::EXPORT, ['EQUAL', 'NOT_EQUAL', 'LIKE', 'IS_NULL', 'IS_NOT_NULL'];
};

done_testing();

