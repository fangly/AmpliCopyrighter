#!/usr/bin/env perl

# data_combiner
# Copyright 2012 Adam Skarshewski
# You may distribute this module under the terms of the GPLv3


=head1 NAME

trait_by_clade_avg - Summarize a trait by clade average

=head1 SYNOPSIS

  trait_by_clade_avg -f XXX

=head1 DESCRIPTION


=head1 REQUIRED ARGUMENTS

=over

=item -i <file>

=for Euclid:
   file.type: readable

=back

=head1 OPTIONAL ARGUMENTS

=over

=back

=head1 AUTHOR

Adam Skarshewski

=head1 BUGS

All complex software has bugs lurking in it, and this program is no exception.
If you find a bug, please report it on the bug tracker:
L<http://github.com/fangly/AmpliCopyrighter/issues>

=head1 COPYRIGHT

Copyright 2012 Adam Skarshewski

Copyrighter is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.
Copyrighter is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
You should have received a copy of the GNU General Public License
along with Copyrighter.  If not, see <http://www.gnu.org/licenses/>.

=cut


use strict;
use warnings;
use List::Util qw(sum);
use Getopt::Euclid qw(:minimal_keys);


open(my $fh, '<', $ARGV{'i'}) or die "Error: Could not read file ".$ARGV{'i'}."\n$!\n";

my @genomes;
my %ranks;

my @dereplication = ({},{},{},{},{},{},{});
while (my $line = <$fh>) {
    chomp $line;
    my @splitline = split /\t/, $line;
    my @img_splittax = split /; /, $splitline[2];
    my @gg_splittax = split /;/, $splitline[4];
    if (scalar @gg_splittax != 7) {
        next;
    }
    # As we are averaging nodes of nodes, we can't have any taxonomies that have missing information.
    if (my $bob = sum(map {$_ =~ /__$/} @gg_splittax)) {
        next;
    }
    my $derep_str = join ';', @gg_splittax[0..6];
    if (defined($dereplication[6]->{$derep_str})) {
        $dereplication[6]->{$derep_str}->{"16S_count"} += $splitline[5];
        $dereplication[6]->{$derep_str}->{genome_size} += $splitline[6];
        $dereplication[6]->{$derep_str}->{count}++;
    } else {
        $dereplication[6]->{$derep_str} = {"16S_count" => $splitline[5],
                                           genome_size => $splitline[6],
                                           count => 1};
    }
}

for(my $i = 5; $i >= 0; $i--) {
    foreach my $lower_tax (keys %{$dereplication[$i+1]}) {
        my @split_lower_tax = split(/;/, $lower_tax);
        my $this_tax = join(';', @split_lower_tax[0..$#split_lower_tax-1]);
        if (defined($dereplication[$i]->{$this_tax})) {
            $dereplication[$i]->{$this_tax}->{"16S_count"} += 
                $dereplication[$i+1]->{$lower_tax}->{"16S_count"} / 
                $dereplication[$i+1]->{$lower_tax}->{count};
            $dereplication[$i]->{$this_tax}->{genome_size} += 
                $dereplication[$i+1]->{$lower_tax}->{genome_size} / 
                $dereplication[$i+1]->{$lower_tax}->{count};
            $dereplication[$i]->{$this_tax}->{count}++;
        } else {
            $dereplication[$i]->{$this_tax} =
                {"16S_count" =>
                    $dereplication[$i+1]->{$lower_tax}->{"16S_count"} /
                    $dereplication[$i+1]->{$lower_tax}->{count},
                 genome_size =>
                    $dereplication[$i+1]->{$lower_tax}->{genome_size} /
                    $dereplication[$i+1]->{$lower_tax}->{count},
                 count => 1};
        }
    }
}


foreach my $rank_hash_ptr (@dereplication) {
    foreach my $tax_string (sort {$a cmp $b} keys %{$rank_hash_ptr}) {
        print(join("\t", ($tax_string,
                          $rank_hash_ptr->{$tax_string}->{count},
                          $rank_hash_ptr->{$tax_string}->{"16S_count"} /
                              $rank_hash_ptr->{$tax_string}->{count},
                          $rank_hash_ptr->{$tax_string}->{genome_size} /
                              $rank_hash_ptr->{$tax_string}->{count})
                  ), "\n");

    }
    print "\n";
}


close($fh);
exit;


