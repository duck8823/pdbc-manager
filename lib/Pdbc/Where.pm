package Pdbc::Where;

use strict;
use warnings FATAL => 'all';

use v5.19;
use feature qw(signatures);
no warnings qw(experimental::signatures);

use Pdbc::Operator;

use Scalar::Util qw(blessed);

use overload (
	q{""}    => \&to_clause,
	fallback => 1,
);

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

sub and($self, $where) {
	if (!defined blessed $where || blessed $where ne 'Pdbc::Where') {
		die 'where should be instance of Pdbc::Where.';
	}
	push @{$self->{and}}, $where;
	return $self;
}

sub or($self, $where) {
	if (!defined blessed $where || blessed $where ne 'Pdbc::Where') {
		die 'where should be instance of Pdbc::Where.';
	}
	push @{$self->{or}}, $where;
	return $self;
}

sub to_clause($self) {
	my $base = $self->_to_phrase;
	return $base ? "WHERE $base" : '';
}

sub _to_phrase($self) {
	my $base;
	if (!defined $self->{column} && !defined $self->{value} && !defined $self->{operator}) {
		$base = '';
	} elsif(!$self->{operator}->has_value) {
		$base = sprintf "%s %s", $self->{column}, $self->{operator};
	} else {
		my $value = $self->{operator} eq LIKE() ? "'%$self->{value}%'" : "'$self->{value}'";
		$base = sprintf "%s %s %s", $self->{column}, $self->{operator}, $value;
	}
	if (defined $self->{and}) {
		my @and_clause = ();
		for my $phrase (@{$self->{and}}) {
			push @and_clause, $phrase->_to_phrase;
		}
		$base .= " AND " if ($base);
		$base = "( $base". join(" AND ", @and_clause) . " )";
	}
	if (defined $self->{or}) {
		my @or_clause = ();
		for my $phrase (@{$self->{or}}) {
			push @or_clause, $phrase->_to_phrase;
		}
		$base .= " OR " if ($base);
		$base = "( $base" . join(" OR ", @or_clause) . " )";
	}
	return $base;
}

1;