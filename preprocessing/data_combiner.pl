#! /usr/bin/env perl

# data_combiner
# Copyright 2012 Adam Skarshewski
# You may distribute this module under the terms of the GPLv3


=head1 NAME

data_combiner - Combine IDs and other data from different sources

=head1 SYNOPSIS

  data_combiner.pl -i img_metadata.tsv -g gg_tax.txt -c 16S_vs_prokMSA.list > output.txt

=head1 DESCRIPTION

The IMG metadata file can be obtained using the export function of IMG
(http://img.jgi.doe.gov/). It should have 13 tab-delimited columns (in this order):
    taxon_oid
    Domain
    Status
    Genome Name
    Phylum
    Class
    Order
    Family
    Genus
    Species
    Genome Size
    Gene Count
    16S rRNA Count

The Greengenes taxonomy file (http://www.secondgenome.com/go/2011-greengenes-taxonomy/) is tab-delimited
and has two columns:
    prokMSA_ID
    GG taxonomy string

The tab-delimited correlation file contains these columns:
    IMG ID (taxon_oid)
    GG ID (prokMSA_ID)
Some of these correspondances can be extracted from GOLD (http://www.genomesonline.org/).

The output of this script is a tab-delimited file containing these columns:
    IMG ID
    IMG Name
    IMG Tax
    GG ID
    GG Tax
    16S Count
    Genome Length
    Gene Count

=head1 AUTHOR

Adam Skarshewski

=head1 BUGS

All complex software has bugs lurking in it, and this program is no exception.
If you find a bug, please report it on the SourceForge Tracker:
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
use threads;
use Getopt::Long;
use File::Basename;

my $options = check_params();

if (! -e $options->{'c'}) {
    "Correlation file doesn't exist: " . $options->{'c'} . "\n";
}

if (! -e $options->{'g'}) {
    "Greengenes taxonomy file doesn't exist: " . $options->{'g'} . "\n";
}

if (! -e $options->{'i'}) {
    "IMG metadata file doesn't exist: " . $options->{'i'} . "\n";
}

# Create GG taxonomies hash
my %gg_taxonomies;
open(my $fh, $options->{'g'}) or die "Error: Could not read file\n$!\n";
while (my $line = <$fh>) {
    chomp $line;
    next if $line =~ m/^#/;
    my @splitline = split /\t/, $line;
    $gg_taxonomies{$splitline[0]} = $splitline[1];
}
close($fh);
warn "Read ".scalar(keys(%gg_taxonomies))." entries from taxonomy file\n"; ###

# Create IMG-GG correlation hash
my %correlations;
open($fh, $options->{'c'}) or die "Error: Could not read file\n$!\n";
while (my $line = <$fh>) {
    chomp $line;
    next if $line =~ m/^#/;
    my @splitline = split /\t/, $line;
    $correlations{$splitline[0]} = $splitline[1];
}
close($fh);
warn "Read ".scalar(keys(%correlations))." entries from correlation file\n"; ###

# Substitutions
print "#IMG ID\tIMG Name\tIMG Tax\tGG ID\tGG Tax\t16S Count\tGenome Length\tGene Count\n";
open($fh, $options->{'i'}) or die "Error: Could not read file\n$!\n";
<$fh>; #burn headers
my $num = 0;
while (my $line = <$fh>) {
    chomp $line;
    next if $line =~ m/^#/;
    $num++;
    my @splitline = split /\t/, $line;
    my $domain = $splitline[1];
    my $status = $splitline[2];
    
    if (! (($domain eq 'Bacteria') || ($domain eq 'Archaea'))) {
        next;
    }
    if ($options->{'finished'}) {
        if (! ($status eq 'Finished')) {
            next;
        }
    }
    
    my $img_id = $splitline[0];
    my $img_name = $splitline[3];
    my $img_tax = join(";", @splitline[4..9]);
    my $GG_id = $correlations{$img_id};
    my $genome_size = $splitline[10];
    my $gene_count = $splitline[11];
    my $rRNA_count = $splitline[12];
    
    if ((defined ($rRNA_count)) && ($rRNA_count > 0)) {
            print(join("\t",($img_id,
                     $img_name,
                     $img_tax,
                     (defined($GG_id) ? $GG_id : "-"),
                     (defined($GG_id) && defined($gg_taxonomies{$GG_id}) ? $gg_taxonomies{$GG_id} : "-"),
                     $rRNA_count,
                     $genome_size,
                     $gene_count
                     )), "\n");
    }

}
close($fh);
warn "Read $num entries from metadata file\n"; ###


################################################################################
# Subroutine: check_params()
# Handles command args via Getopt::Long and returns a reference to a hash of
# options.
################################################################################


sub check_params {
    my @standard_options = ( "help+", "man+");
    my %options;
    GetOptions( \%options, @standard_options, "i:s", "c:s",  "g:s", "-finished");
    exec("pod2usage $0") if $options{'help'};
    exec("perldoc $0")   if $options{'man'};
    exec("pod2usage $0") if (!( $options{'c'} && $options{'g'} && $options{'i'}));
    return \%options;
}

