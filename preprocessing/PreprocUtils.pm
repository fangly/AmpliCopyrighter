package PreprocUtils;

use strict;
use warnings;
use Method::Signatures;
use Statistics::Basic qw(mean);


func find_column_for ($header_line, @field_names) {
   # Given a tab-separated header line, find which column matches the given name.
   # Search is insensitive to case, spaces, underscores and dashes. Also, note
   # that matches only need to be partial.
   my @fields = split /\t/, $header_line;
   # Make names and cols insensitive
   for my $arr ( \@fields, \@field_names ) {
      for my $i (0 .. scalar @$arr - 1) {
         $arr->[$i] =~ s/[\s_-]//g;
         $arr->[$i] = lc $arr->[$i];
      }
   }
   # Look for names in column headers
   my @col_nums;
   for my $name (@field_names) {
      my $col_num;
      for ($col_num = 0; $col_num < scalar @fields; $col_num++) {
         my $field = $fields[$col_num];
         if ($field =~ m/$name/) {
            push @col_nums, $col_num;
            last;
         }
      }
      if (not defined $col_num) {
         die "Error: Could not find column holding '$name' data\n";
      }
   }
   return @col_nums;
}


func read_lookup ($file) {
   # Read a 2-column, tab-delimited lookup file (e.g. Greengenes taxonomy,
   # img_to_gg, etc)
   my $lookup;
   open my $fh, '<', $file or die "Error: Could not read file $file\n$!\n";
   while (my $line = <$fh>) {
      chomp $line;
      next if $line =~ m/^#/;
      my ($key, $val) = split /\t/, $line;
      $lookup->{$key} = $val;
   }
   close $fh;
   return $lookup;
}


func average_by_key ( $hash, Int $digits? ) {
   # Given a hash of arrays, make the average of the arrays by key. When the
   # average of more than one value, use the specified optional number of decimal
   # digits.
   for my $key (keys %$hash) {
      my $vals = $hash->{$key};
      if (ref($vals) eq 'ARRAY') {
         my $mean = mean($vals)->query;
         if ( (scalar @$vals > 1) && (defined $digits) ) {
            $mean = sprintf( "%.".$digits."f" , $mean );
         }
         $hash->{$key} = $mean;
      } # else do nothing, keep the single value
   }
   return $hash;
}


1;
