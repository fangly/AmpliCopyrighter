#! perl

use strict;
use warnings;
use Test::More;


BEGIN {
   use_ok('t::TestUtils');
}

#diag( "Testing Copyrighter version $Grinder::VERSION, Perl $], $^X" );
diag( "Testing Copyrighter, Perl $], $^X" );

ok run_copyrighter(['--help']);
ok run_copyrighter(['--man']);
ok run_copyrighter(['--usage']);
ok run_copyrighter(['--version']);


done_testing();
