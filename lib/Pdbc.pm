package Pdbc;

use strict;
use warnings FATAL => 'all';

use v5.19;
use feature 'signatures';
no warnings 'experimental::signatures';

use Exporter;
our (@ISA, @EXPORT, @EXPORT_OK);
@ISA = qw(Exporter);
@EXPORT = qw(EQUAL NOT_EQUAL LIKE struct);
@EXPORT_OK = qw(connect);

use Pdbc::Manager;
use Pdbc::Where qw(EQUAL NOT_EQUAL LIKE);

sub connect {
	scalar @_ > 4 and die "too many arguments$!";
	my ($driver, $datasource, $user, $password) = @_;
	return Pdbc::Manager->new($driver, $datasource, $user, $password);
}

sub struct($typename, $field_names) {
	my $members;
	my $columns;
	for (my $i = 0; $i < @$field_names; $i++) {
		$members .= "		$$field_names[$i] => \$$$field_names[$i],\n";
		$$columns[$i] = '$' . $$field_names[$i];
	}
	my $args = join(', ', @$columns);
	eval << "EOS";
BEGIN {
package $typename;

use 5.019;
use feature 'signatures';
no warnings 'experimental::signatures';

sub new(\$pkg, $args) {
	my \$self = {
$members
	};
	return bless \$self, ref(\$pkg) || \$pkg;
}
1;
}
EOS

	die $@ if $@;
	my $caller = caller;
	no strict 'refs';
	*{"${caller}::${typename}"} = sub {
		return bless $field_names, $typename;
	};
	use strict 'refs';
}

1;