package Pdbc::FromCase;

use strict;
use warnings FATAL => 'all';

use v5.19;
use feature 'signatures';
no warnings 'experimental::signatures';

use Pdbc::Where;
use Pdbc::Executable;

sub new($pkg, $db, $entity) {
	my $self = {
		_db		=> $db,
		_entity	=> $entity,
		_where	=> Pdbc::Where->new(undef, undef, undef)
	};
	return bless $self, $pkg;
}

sub where($self, $where) {
	$self->{_where} = $where;
	return $self;
}

sub list($self) {
	my $results;
	my $sth = $self->{_db}->prepare(sprintf("SELECT %s FROM %s %s", join(', ', @{$self->{_entity}}) , ref $self->{_entity}, $self->{_where}->to_string()));
	$sth->execute();
	for my $result (@{$sth->fetchall_arrayref(+{})}) {
		push @$results, bless($result, ref($self->{_entity}));
	}
	return $results;
}

sub single_result($self) {
	my $result = $self->list();
	scalar @$result > 1 and die '結果が一意でありません.';
	return $result->[0];
}

sub delete($self) {
	return Pdbc::Executable->new($self->{_db}, sprintf("DELETE FROM %s %s", ref $self->{_entity}, $self->{_where}->to_string()));
}

1;