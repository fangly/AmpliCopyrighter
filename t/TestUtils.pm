package t::TestUtils;


use strict;
use warnings;
use IPC::Run;


use vars qw{@ISA @EXPORT};
BEGIN {
   @ISA     = 'Exporter';
   @EXPORT  = qw{
      run_copyrighter
      round
   };
}


#------------------------------------------------------------------------------#

sub run_copyrighter {
   # Run copyrighter with the specified argument
   my ($args) = @_;
   my @cmd = ('scripts/copyrighter', @$args);
   my $err_msg = "Error: The following command returned status $?:\n".
                 join(' ', @cmd)."\n";
   #IPC::Run::run( \@cmd ) or die $err_msg;
   #return 1;
   return IPC::Run::run( \@cmd );
}


sub round {
   # Round the number given as argument
   return int(shift() + 0.5);
}


1;
