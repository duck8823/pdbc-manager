package Pdbc::Updatecase;

use strict;
use warnings FATAL => 'all';

use v5.19;
use feature 'signatures';
no warnings 'experimental::signatures';

use Pdbc::Where;
use Pdbc::Executable;

our @ISA;
@ISA = qw(Pdbc::Executable);

sub new($pkg, $db, $data) {
	my $self = Pdbc::Executable->new($db, sprintf("UPDATE %s SET %s", ref $data, &_create_update_clause($data)));
	return bless $self, $pkg;
}

sub where($self, $where) {
	$self->{_sql} =~ s/\sWHERE\s.*$//;
	$self->{_sql} .= ' ' . $where->to_clause;
	return $self;
}

sub _create_update_clause($data) {
	my @set;
	for my $column (sort keys %$data) {
		my $value;
		if (defined $data->{$column}) {
			($value = $data->{$column}) =~ s/'/''/g;
			$value = "'$value'";
		} else {
			$value = 'NULL';
		}
		push(@set, sprintf "%s = %s", $column, $value);
	}
	return join(', ', @set);
}

1;