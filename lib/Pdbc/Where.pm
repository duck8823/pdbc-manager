package Pdbc::Where;

use strict;
use warnings FATAL => 'all';

use v5.19;
use feature qw(signatures);
no warnings qw(experimental::signatures);

use Exporter;
our (@ISA, @EXPORT);
@ISA = qw(Exporter);
@EXPORT = qw(EQUAL NOT_EQUAL LIKE);

sub new($pkg, $column, $value, $operator) {
	my $self = {
		column   => $column,
		value    => $value,
		operator => $operator
	};
	return bless $self, $pkg;
}

sub to_string($self) {
	if (!defined $self->{column} && !defined $self->{value} && !defined $self->{operator}) {
		return '';
	} elsif (ref(\$self->{value}) ne 'SCALAR' || (defined $self->{column} && !defined $self->{value}) || (!defined $self->{column} && defined $self->{value})) {
		die sprintf("error %s", $self);
	}
	my $value = $self->{value};
	if($self->{operator} eq &LIKE) {
		$value = '%' . $value . '%';
	}
#	use Switch;
#	switch ($self->{operator}) {
#		case (&LIKE) {
#			$value = '%'.$value.'%'
#		}
#	}
	return sprintf "WHERE %s %s '%s'", $self->{column}, $self->{operator}, $value;
}

sub EQUAL {
	return '='
}
sub NOT_EQUAL {
	return '<>';
}
sub LIKE {
	return 'LIKE';
}


1;