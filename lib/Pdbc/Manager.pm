package Pdbc::Manager;

use strict;
use warnings FATAL => 'all';

use v5.19;
use feature 'signatures';
no warnings 'experimental::signatures';

use DBI;
use Pdbc::FromCase;
use Pdbc::Executable;


sub new($pkg, $driver, $datasource) {
	my $self = {
		_driver => $driver,
		_datasource => $datasource
	};
	$self->{_connection} = DBI->connect("dbi:$self->{_driver}:$self->{_datasource}") or die $!;
	return bless $self, $pkg;
}

sub from($self, $entity) {
	return Pdbc::FromCase->new($self, $entity);
}

sub drop($self, $entity) {
	return Pdbc::Executable->new($self, sprintf("DROP TABLE IF EXISTS %s", ref $entity));
}

sub create($self, $entity) {
	my @column;
	for my $column (sort keys %$entity) {
		my $type = $entity->{$column};
		grep {$_ eq $type} ('INTEGER', 'TEXT', 'BOOLEAN') or die sprintf("次の型は対応していません. :%s", $type);
		push @column, sprintf("'%s' %s", $column, $type);
	}
	return Pdbc::Executable->new($self, sprintf("CREATE TABLE %s (%s)", ref $entity, join(', ', @column)));
}

sub insert($self, $data) {
	return Pdbc::Executable->new($self, sprintf("INSERT INTO %s %s", ref $data, &_create_sentence($data)));
}

sub _create_sentence($data) {
	my @column;
	my @value;
	for my $column (sort keys %$data) {
		push @column, $column;
		push @value, sprintf("'%s'", defined $data->{$column} ? $data->{$column} : '');
	}
	return sprintf "(%s) VALUES (%s)", join(', ', @column), join(', ', @value);
}

1;