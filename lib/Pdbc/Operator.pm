package Pdbc::Operator;

use strict;
use warnings FATAL => 'all';

use v5.19;
use feature qw(signatures);
no warnings qw(experimental::signatures);

use Exporter;
our (@ISA, @EXPORT);
@ISA = qw(Exporter);
@EXPORT = qw(EQUAL NOT_EQUAL LIKE IS_NULL IS_NOT_NULL);

use overload (
	q{""}    => \&as_string,
	fallback => 1,
);

sub __new($pkg, $scalar, $has_value) {
	return bless {
		scalar => $scalar,
		has_value => $has_value
	}, $pkg;
}

sub has_value($self) {
	return $self->{has_value}
}

sub as_string {
	my $self = shift;
	return $self->{scalar};
}

sub EQUAL {
	return Pdbc::Operator->__new('=', 1);
}
sub NOT_EQUAL {
	return Pdbc::Operator->__new('<>', 1);
}
sub LIKE {
	return Pdbc::Operator->__new('LIKE', 1);
}
sub IS_NULL {
	return Pdbc::Operator->__new('IS NULL', undef);
}
sub IS_NOT_NULL {
	return Pdbc::Operator->__new('IS NOT NULL', undef);
}

1;