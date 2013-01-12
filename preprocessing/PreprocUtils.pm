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
      next if $line =~ m/^\s*$/;
      my ($key, $val) = split /\t/, $line;
      $lookup->{$key} = $val;
   }
   close $fh;
   return $lookup;
}


func average_by_key ( $hash, $weight_hash ) {
   # Given a hash of arrays, make the average of the arrays by key. 

   ###
   use Data::Dumper;
   warn "HASH: ".Dumper($weight_hash);
   warn "WEIGHT_HASH: ".Dumper($weight_hash);
   ###

###   if (defined $weight_hash) {
###      die "Error: Weighted average not yet supported\n";
###   }

   for my $key (keys %$hash) {
      my $vals = $hash->{$key};
      if (ref($vals) eq 'ARRAY') {
         my $mean = 0;
         if (defined $weight_hash) {
            # Weighted mean
            my $total = 0;
            my $weights = $weight_hash->{$key};
            for my $weight (@$weights) {
               $total += $weight;
            }
            for my $i (0 .. scalar @$vals) {
               my $val = $vals->[$i];
               my $weight = $weights->[$i];
               $mean += $val * $weight;
            }
            $mean /= $total;
         } else {
            # Simple mean
            $mean = mean($vals)->query;
         }
         # Number of decimal digits to use
         #if ( (scalar @$vals > 1) && (defined $digits) ) {
         #   $mean = sprintf( "%.".$digits."f" , $mean );
         #}
         $hash->{$key} = $mean;
      } # else do nothing, keep the single value
   }
   return $hash;
}


func write_tree ($tree, $file) {
   open my $out, '>', $file or die "Error: Could not write file $file\n$!\n";
   print $out Bio::Phylo::IO->unparse(
      -phylo      => $tree,
      -format     => 'newick',
      -nodelabels => 1, # report name of internal nodes
   );
   close $out;
   return 1;
}


1;
