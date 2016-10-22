package Pdbc::Where;

use strict;
use warnings FATAL => 'all';

use v5.19;
use feature qw(signatures);
no warnings qw(experimental::signatures);

use Pdbc::Operator;

use Scalar::Util qw(blessed);

sub new {
	my ($pkg, $column, $value, $operator) = shift;
	my $num_of_args = scalar @_;
	if ($num_of_args == 0) {
		#break
	} elsif ($num_of_args == 2) {
		($column, $operator) = @_;
	} elsif ($num_of_args == 3) {
		($column, $value, $operator) = @_;
	} else {
		die 'invalid argument number.';
	}
	if ((!defined $column && defined $operator) || (defined $column && !defined $operator) || (!defined $column && !defined $operator && defined $value)) {
		die sprintf('invalid argument.');
	}

	if (defined $column && ref \$column ne 'SCALAR') {
		die sprintf('column should be SCALAR: %s', ref \$column);
	} elsif (defined $operator && (!defined blessed $operator || blessed $operator ne 'Pdbc::Operator')) {
		die sprintf('operator should be Pdbc::Operator type: %s', $operator);
	}

	return bless {
		column   => $column,
		value    => $value,
		operator => $operator
	}, $pkg;
}

sub to_clause($self) {
	if (!defined $self->{column} && !defined $self->{value} && !defined $self->{operator}) {
		return '';
	}
	my $value = $self->{value};
	if (!$self->{operator}->has_value) {
		return sprintf "WHERE %s %s", $self->{column}, $self->{operator};
	} elsif($self->{operator} eq LIKE) {
		$value = "'%$value%'";
	} else {
		$value = "'$value'";
	}
	return sprintf "WHERE %s %s %s", $self->{column}, $self->{operator}, $value;
}


1;