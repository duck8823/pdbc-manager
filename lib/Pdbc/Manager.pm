package Pdbc::Manager;

use strict;
use warnings FATAL => 'all';

use v5.19;
use feature 'signatures';
no warnings 'experimental::signatures';

use DBI;
use Pdbc::FromCase;
use Pdbc::UpdateCase;
use Pdbc::Executable;


sub new {
	my ($pkg, $driver, $datasource, $user, $password) = @_;
	my $db = DBI->connect("dbi:$driver:$datasource", $user, $password, { PrintError => 0 }) or die DBI::errstr;
	my $self = {
		_db => $db
	};
	return bless $self, $pkg;
}

sub from($self, $entity) {
	return Pdbc::FromCase->new($self->{_db}, $entity);
}

sub drop($self, $entity) {
	return Pdbc::Executable->new($self->{_db}, sprintf("DROP TABLE IF EXISTS %s", ref $entity));
}

sub create($self, $entity) {
	my @column;
	for my $column (sort keys %$entity) {
		my $type = $entity->{$column};
		grep {$_ eq $type} ('INTEGER', 'TEXT', 'BOOLEAN') or die sprintf("次の型は対応していません. :%s", $type);
		push @column, sprintf("%s %s", $column, $type);
	}
	return Pdbc::Executable->new($self->{_db}, sprintf("CREATE TABLE %s (%s)", ref $entity, join(', ', @column)));
}

sub insert($self, $data) {
	return Pdbc::Executable->new($self->{_db}, sprintf("INSERT INTO %s %s", ref $data, &_create_insert_clause($data)));
}

sub update($self, $data) {
	return Pdbc::Updatecase->new($self->{_db}, $data);
}

sub begin($self) {
	$self->{_db}->begin_work;
}

sub commit($self) {
	$self->{_db}->commit;
}

sub rollback($self) {
	$self->{_db}->rollback;
}

sub _create_insert_clause($data) {
	my (@column, @value);
	for my $column (sort keys %$data) {
		push @column, $column;
		my $value;
		if (defined $data->{$column}) {
			($value = $data->{$column}) =~ s/'/''/g;
			$value = "'$value'";
		} else {
			$value = 'NULL';
		}
		push @value, $value;
	}
	return sprintf "(%s) VALUES (%s)", join(', ', @column), join(', ', @value);
}

1;