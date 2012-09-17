#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;
use Data::Dumper;
use Statistics::Basic qw(mean stddev);

my $options = check_params();

open(my $fh, "<", $options->{'f'});

my @genomes;
my %ranks;

my %dereplication;
while (my $line = <$fh>) {
    chomp $line;
    my @splitline = split /\t/, $line;
    my @img_splittax = split /; /, $splitline[2];
    my @gg_splittax = split /;/, $splitline[4];
    if (scalar @gg_splittax != 7) {
        next;
    }
    my $derep_str = join ';', @gg_splittax[0..5];
    #my $dereplication_string = join ';', @img_splittax[0..5];
    if (defined($dereplication{$derep_str})) {
        $dereplication{$derep_str}->{"16S_count"} += $splitline[5];
        $dereplication{$derep_str}->{genome_size} += $splitline[6];
        $dereplication{$derep_str}->{count}++;
    } else {
        $dereplication{$derep_str} = {tax => \@gg_splittax,
                                                 "16S_count" => $splitline[5],
                                                 genome_size => $splitline[6],
                                                 count => 1};
    }
}

print Dumper (\%dereplication);
exit;

foreach my $derep_str (keys %dereplication) {
    my @gg_splittax = @{$dereplication{$derep_str}->{tax}};
    my $count = $dereplication{$derep_str}->{count};
    my $rRNA_count = $dereplication{$derep_str}->{"16S_count"} / $count;
    my $genome_size = $dereplication{$derep_str}->{genome_size} / $count;
    for(my $i = 1; $i <= 6; $i++) {
        my @rank_tax;
        for (my $j = 1; $j <= $i; $j++) {
            push @rank_tax, $gg_splittax[$j-1];
        }
        # Final rank must be classified
        if ($rank_tax[-1] =~ /^[kpcofgs]__$/) {
            next;
        }
        my $tax_string = join(";", @rank_tax);
        push @{$ranks{$i}->{$tax_string}}, {genome_size => $genome_size,
                                            "16S_count" => $rRNA_count}
    }   
}

print join("\t", ("Taxonomy", "Num. Genera", "Mean", "StdDev")), "\n";
foreach my $rank (sort {$a <=> $b} keys %ranks) {
    foreach my $tax_string (sort {$a cmp $b} keys %{$ranks{$rank}}) {
        my @genome_lengths;
        my @rRNA_counts;
        #if (scalar @{$ranks{$rank}->{$tax_string}} < 4) {
        #    next;
        #}
        foreach my $stats (@{$ranks{$rank}->{$tax_string}}) {
            push @genome_lengths, $stats->{genome_size};
            push @rRNA_counts, $stats->{"16S_count"};
        }
        print join("\t", ($tax_string, scalar @rRNA_counts, mean(@rRNA_counts), stddev(@rRNA_counts)
                          #mean(@genome_lengths), median(@genome_lengths), stddev(@genome_lengths)
                          )), "\n";
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

