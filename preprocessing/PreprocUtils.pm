package PreprocUtils;

use strict;
use warnings;
use Method::Signatures;
use POSIX qw(ceil floor);
use Statistics::Basic qw(mean);
use Bio::Phylo::Treedrawer;


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


func average_by_key ( $hash, $weight_hash? ) {
   # Given a hash of arrays, make the average of the arrays by key. Note that
   # the modifications are done IN PLACE on both the hash of values and of
   # weights
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
            $weight_hash->{$key} = $total;
            for my $i (0 .. scalar @$vals - 1) {
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
   if (defined $weight_hash) {
      return $hash, $weight_hash;
   } else {
      return $hash;
   }
}


func write_tree ($tree, Str $file) {
   # Write a tree object or string in a Newick file
   open my $out, '>', $file or die "Error: Could not write file $file\n$!\n";
   my $str;
   if (ref $tree eq 'Bio::Phylo::Forest::Tree') {
      $str = Bio::Phylo::IO->unparse(
         -phylo      => $tree,
         -format     => 'newick',
         -nodelabels => 1, # report name of internal nodes
      );
   } else {
      $str = $tree;
   }
   print $out $str;
   close $out;
   return 1;
}


func draw_tree (Bio::Phylo::Forest::Tree $tree, Str $file, Str $mode = 'phylo', Str $shape = 'rect') {
   # Draw a tree in a SVG file. Two options control the appearance:
   #    - mode : phylo or clado
   #    - shape: rect, diag, curvy or radial
   my $treedrawer = Bio::Phylo::Treedrawer->new(
      #-width  => 1200,
      #-height =>  800,
      -shape  => $shape,
      -mode   => $mode,
      -format => 'svg'
   );
   #$treedrawer->set_width(1000);
   $treedrawer->set_node_radius(3);
   $treedrawer->set_tree($tree);
   open my $out, '>', $file or die "Error: Could not write file $file\n$!\n";
   print $out $treedrawer->draw;
   close $out;
   return 1;
}


func ssu_thr ($mean_copy) {
   # Using rrNDB, it looks like there is a linear relation between the max
   # difference D between a copy number for a genome and the average copy number
   # X of the species that this genome is from: D = 0.10377 X + 0.72642
   my $thr = 0.10377 * $mean_copy + 0.72642;
   return $thr;
}


func near_avg ($val, $mean, $stddev) {
   return (abs($mean-$val) > 3*$stddev) ? 0 : 1;

}

func near_avg_ssu ($copy_num, $mean_copy, Int $mult = 1) {
   # Check that the difference between the given copy number (an integer) and
   # species average is under the maximum allowed threshold (w 20% error margin)
   my $thr   = 1.2 * $mult * ssu_thr($mean_copy);
   my $max   = ceil(  $mean_copy + $thr );
   my $min   = floor( $mean_copy - $thr );
   if ($min < 1) {
      $min = 1;
   }
   my $is_near;
   if ( ($copy_num >= $min) && ($copy_num <= $max) ) {
      $is_near = 1;
   } else {
      $is_near = 0;
   }
   return $is_near;
}


1;
