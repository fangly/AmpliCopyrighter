#!/usr/bin/perl
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
open(my $fh, $options->{'g'}) or die;
while (my $line = <$fh>) {
    chomp $line;
    my @splitline = split /\t/, $line;
    $gg_taxonomies{$splitline[0]} = $splitline[1];
}
close($fh);

# Create IMG-GG correlation hash
my %correlations;
open($fh, $options->{'c'}) or die;
while (my $line = <$fh>) {
    chomp $line;
    my @splitline = split /\t/, $line;
    $correlations{$splitline[0]} = $splitline[1];
}
close($fh);

# Substitutions
print "#IMG ID\tIMG Name\tIMG Tax\tGG ID\tGG Tax\t16S Count\tGenome Length\tGene Count\n";
open($fh, $options->{'i'}) or die;
<$fh>; #burn headers
while (my $line = <$fh>) {
    chomp $line;
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

__DATA__

=head1 NAME

    
   
=head1 DESCRIPTION

The metadata file is expected to contain 13 columns (in this order):
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

=head1 SYNOPSIS


=cut
