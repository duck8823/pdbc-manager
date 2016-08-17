package Pdbc::Executable;

use strict;
use warnings FATAL => 'all';

use v5.19;
use feature 'signatures';
no warnings 'experimental::signatures';

sub new($pkg, $manager, $sql) {
	my $self = {
		_manager => $manager,
		_sql     => $sql
	};
	return bless $self, $pkg;
}

sub execute($self) {
	my $sth = $self->{_manager}->{_connection}->prepare($self->{_sql});
	$sth->execute();
}

sub get_sql($self) {
	return $self->{_sql};
}

1;