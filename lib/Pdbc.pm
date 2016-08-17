package Pdbc;

use strict;
use warnings FATAL => 'all';

use v5.19;
use feature 'signatures';
no warnings 'experimental::signatures';

use Exporter;
our (@ISA, @EXPORT, @EXPORT_OK);
@ISA = qw(Exporter);
@EXPORT = qw(EQUAL NOT_EQUAL LIKE);
@EXPORT_OK = qw(connect);

use Pdbc::Manager;
use Pdbc::Where qw(EQUAL NOT_EQUAL LIKE);

sub connect($driver, $datasource) {
	return Pdbc::Manager->new($driver, $datasource);
}


1;