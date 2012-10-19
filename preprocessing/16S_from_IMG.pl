#!/usr/bin/env perl


=head1 NAME

16S_from_IMG.pl
 
=head1 DESCRIPTION

Gets 16S sequences from folders of IMG taxon ids (with gffs and gene fasta files)
    
=head1 SYNOPSIS

  16S_from_IMG.pl -i <folder_containing_taxon_subfolders>
        -i      Input directory
        
=cut

use strict;
use warnings;

use Getopt::Long;
use Bio::SeqIO;
use File::Spec;


my $options = check_params();

if (! -e $options->{'i'}) {
    die sprintf("Unable to proceed. Input directory not found: %s\n", $options->{'i'});
}

my %genes;

my $out_fh = Bio::SeqIO->new(-format => 'fasta');

my $input_dir = $options->{'i'};
opendir my $dh, $input_dir or die "Error: Could not read folder $input_dir\n$!\n";
while (my $entry = readdir($dh)) {
   my $gff_file = File::Spec->catfile($input_dir, $entry, "$entry.gff");
   if (-e $gff_file) {
      open my $fh, '<', $gff_file or die "Error: Could not read file $gff_file\n$!\n";
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
closedir $dh;

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

