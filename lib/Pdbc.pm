package Pdbc;

use strict;
use warnings FATAL => 'all';

use v5.19;
use feature 'signatures';
no warnings 'experimental::signatures';

use Exporter;
our (@ISA, @EXPORT_OK);
@ISA = qw(Exporter);
@EXPORT_OK = qw(connect);

use Pdbc::Manager;
use Pdbc::Where;

sub connect($driver, $datasource) {
	return Pdbc::Manager->new($driver, $datasource);
}


1;