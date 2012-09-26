#!/usr/bin/env perl
use strict;
use warnings;

use Getopt::Long;
use Data::Dumper;
use Bio::SeqIO;

my $options = check_params();

if (! -e $options->{'i'}) {
    die sprintf("Unable to proceed. Input directory not found: %s\n", $options->{'i'});
}

my %genes;

my $out_fh = Bio::SeqIO->new(-format => 'fasta');

opendir(my $dh, $options->{'i'});
while(my $entry = readdir($dh)) {
    if (-e $options->{'i'} . "/$entry/$entry.gff") {
        open(my $fh, "<", $options->{'i'} . "/$entry/$entry.gff");
        while (my $line = <$fh>) {
            chomp $line;
            my @splitline = split /\t/, $line;
            if (scalar(@splitline) < 9) {
                next;
            }
            if ($splitline[2] eq 'rRNA') {
                if ($splitline[8] =~ /16[Ss]/ && $splitline[8] =~ /ID=(\d+)/) {
                    $genes{$1} = $entry;   
                }
            }
        }
        if (-e $options->{'i'} . "/$entry/$entry.genes.fna") {
            my $in_fh = Bio::SeqIO->new(-format => 'fasta',
                                        -file => $options->{'i'} .
                                                 "/$entry/$entry.genes.fna");
            while (my $seq_obj = $in_fh->next_seq()) {
                if (exists($genes{$seq_obj->id()})) {
                    $seq_obj->id($genes{$seq_obj->id()} . "_" . $seq_obj->id());
                    $out_fh->write_seq($seq_obj)
                }
            }
        }
    }
}
closedir($dh);

################################################################################
# Subroutine: check_params()
# Handles command args via Getopt::Long and returns a reference to a hash of
# options.
################################################################################

sub check_params {
    my @standard_options = ( "help+", "man+");
    my %options;
    GetOptions( \%options, @standard_options, "i:s");
    exec("pod2usage $0") if $options{'help'};
    exec("perldoc $0")   if $options{'man'};
    exec("pod2usage $0") if (!($options{'i'}));
    return \%options;
}

__DATA__

=head1 NAME

	16S_from_IMG.pl  
 
=head1 DESCRIPTION

    Gets 16S sequences from folders of IMG taxon ids (with gffs and gene fasta files)
    
=head1 SYNOPSIS

    16S_from_IMG.pl -i <folder_containing_taxon_subfolders>

        -i      Input directory

        
=cut
