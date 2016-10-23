use strict;
use warnings FATAL => 'all';

use v5.19;

use Module::Build;

Module::Build->new(
	module_name => 'Pdbc::Manager'
)->create_build_script;