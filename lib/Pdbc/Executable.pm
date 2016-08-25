package Pdbc::Executable;

use strict;
use warnings FATAL => 'all';

use v5.19;
use feature 'signatures';
no warnings 'experimental::signatures';

sub new($pkg, $db, $sql) {
	my $self = {
		_db => $db,
		_sql     => $sql
	};
	return bless $self, $pkg;
}

sub execute($self) {
	my $sth = $self->{_db}->prepare($self->{_sql});
	$sth->execute();
}

sub get_sql($self) {
	return $self->{_sql};
}

1;