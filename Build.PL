use strict;
use warnings FATAL => 'all';

use v5.19;

use Module::Build;

my $build = Module::Build->new(
	module_name => 'Pdbc::Manager',
	lisence => 'mit',
	requires => {
		'perl' => '5.019',
		'Exporter' => '5.72',
		'DBI' => '1.636',
		'DBD::SQLite' => '1.50',
		'DBD::Pg' => '3.5.3',
		'Test::More' => '0.98',
		'Test::Exception' => '0.43'
	}
);
$build->create_build_script;