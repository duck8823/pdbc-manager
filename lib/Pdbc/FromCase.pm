package Pdbc::FromCase;

use strict;
use warnings FATAL => 'all';

use v5.19;
use feature 'signatures';
no warnings 'experimental::signatures';

use Pdbc::Where;
use Pdbc::Executable;

sub new($pkg, $manager, $entity) {
	my $self = {
		_manager => $manager,
		_entity  => $entity,
		_where   => Pdbc::Where->new(undef, undef, undef)
	};
	return bless $self, $pkg;
}

sub where($self, $where) {
	$self->{_where} = $where;
	return $self;
}

sub list($self) {
	my $sth = $self->{_manager}->{_connection}->prepare(sprintf("SELECT %s FROM %s %s", join(', ', keys %{$self->{_entity}}) , ref $self->{_entity}, $self->{_where}->to_string()));
	$sth->execute();
	return $sth->fetchall_arrayref(+{})
}

sub single_result($self) {
	my $result = $self->list();
	scalar @$result > 1 and die '結果が一意でありません.';
	return $result->[0];
}

sub delete($self) {
	return Pdbc::Executable->new($self->{_manager}, sprintf("DELETE FROM %s %s", ref $self->{_entity}, $self->{_where}->to_string()));
}

1;