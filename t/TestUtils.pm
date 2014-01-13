package t::TestUtils;


use strict;
use warnings;
use IPC::Run;
use File::Spec::Functions;


use vars qw{@ISA @EXPORT};
BEGIN {
   @ISA     = 'Exporter';
   @EXPORT  = qw{
      data
      run_copyrighter
   };
}


#------------------------------------------------------------------------------#


sub data {
   # Get the complete filename of a test data file
   return catfile('t', 'data', @_);
}


sub run_copyrighter {
   # Run copyrighter with the specified argument
   my ($args) = @_;
   my $script = catfile('scripts', 'copyrighter');
   my @cmd = ($script, @$args);
   my $err_msg;
   IPC::Run::run( \@cmd, '2>', \$err_msg ) or die $err_msg;
   return 1;
}


1;
