use strict;
use warnings FATAL => 'all';

use Test::More;
use Test::Exception;

use Pdbc;

BEGIN {
	struct 'Test', ['id', 'name'];
}

subtest 'new', sub {
	my $updatecase = Pdbc::Updatecase->new(undef, Test->new(1, 'name_1'));
	isa_ok $updatecase, 'Pdbc::Updatecase';

	is $updatecase->{_sql}, "UPDATE Test SET id = '1', name = 'name_1'";
};

subtest 'where', sub {
	my $updatecase = Pdbc::Updatecase->new(undef, Test->new(1, 'name_1'));
	$updatecase->where(Pdbc::Where->new('id', 1, EQUAL));

	is $updatecase->{_sql}, "UPDATE Test SET id = '1', name = 'name_1' WHERE id = '1'";

	$updatecase->where(Pdbc::Where->new('name', IS_NOT_NULL));
	is $updatecase->{_sql}, "UPDATE Test SET id = '1', name = 'name_1' WHERE name IS NOT NULL";
};

subtest 'create_update_clause', sub {
	my $actual = Pdbc::Updatecase::_create_update_clause(Test->new(1, 'name_1'));
	is $actual, "id = '1', name = 'name_1'";

	$actual = Pdbc::Updatecase::_create_update_clause(Test->new(2, undef));
	is $actual, "id = '2', name = NULL";
};

done_testing();