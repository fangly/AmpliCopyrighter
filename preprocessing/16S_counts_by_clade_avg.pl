#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;
use Data::Dumper;
use List::Util qw(sum);

my $options = check_params();

open(my $fh, "<", $options->{'f'});

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

#print Dumper(\@dereplication);


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

################################################################################
# Subroutine: check_params()
# Handles command args via Getopt::Long and returns a reference to a hash of
# options.
################################################################################

sub check_params {
    my @standard_options = ( "help+", "man+");
    my %options;
    GetOptions( \%options, @standard_options, "f:s");
    exec("pod2usage $0") if $options{'help'};
    exec("perldoc $0")   if $options{'man'};
    exec("pod2usage $0") if (!( $options{'f'}));
    return \%options;
}

