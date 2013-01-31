use inc::Module::Install;


# Package information

name     'Copyrighter';
all_from 'scripts/copyrighter';
license  'gpl3'; # Module::Install 1.04 does not parse the GPL version number

resources
   homepage   'http://github.com/fangly/AmpliCopyrighter';
   bugtracker 'http://github.com/fangly/AmpliCopyrighter/issues';
   repository 'git://github.com/fangly/AmpliCopyrighter.git';


# Dependencies for main copyrighter script

build_requires 'Test::More'                       =>  0;
requires       'Bio::Community'                   =>  0; # from Bio-Community
requires       'Method::Signatures'               =>  0;
requires       'Getopt::Euclid'                   => '0.3.4';


# Dependencies for utilities in ./preprocessing/ (not installed by default)

#requires       'Bio::Phylo'                       =>  0; # from bio-phylo
#requires       'Bio::PrimarySeq'                  =>  0; # from bioperl-live
#requires       'Bio::SearchIO'                    =>  0; # from bioperl-live
#requires       'Bio::SeqIO'                       =>  0; # from bioperl-live
#requires       'Bio::DB::Fasta'                   =>  0; # from bioperl-live dev version
#requires       'Bio::Tools::Run::Alignment::Blat' =>  0; # from bioperl-run
#requires       'IPC::Run'                         =>  0;
#requires       'Math::Gradient'                   =>  0;
#requires       'Statistics::Basic'                =>  0;
#requires       'SVG'                              =>  0;
#requires       'SVG::Parser'                      =>  0;


# Dependencies for developpers only

author_requires 'Module::Install';
author_requires 'Module::Install::AuthorRequires';
author_requires 'Module::Install::AutoLicense';
author_requires 'Module::Install::ReadmeFromPod' => 0.14;
author_requires 'Module::Install::AutoManifest';


# Install dependencies

auto_install;


# Scripts to install: main copyrighter script

install_script 'scripts/copyrighter';


# Extra scripts: preprocessing utilities

#install_script 'preprocessing/data_combiner';
#install_script 'preprocessing/draw_trait_dist';
#install_script 'preprocessing/estimate_species_trait';
#install_script 'preprocessing/extract_ssu_seqs';
#install_script 'preprocessing/fix_img_copy_number';
#install_script 'preprocessing/fix_img_taxonomy';
#install_script 'preprocessing/img_gg_matcher';
#install_script 'preprocessing/PreprocUtils.pm';
#install_script 'preprocessing/trait_by_clade';
#install_script 'preprocessing/trait_by_clade_pic';
#install_script 'preprocessing/trait_by_clade_weighted';
#install_script 'preprocessing/trait_by_genome';
#install_script 'preprocessing/use_cluster_repr';



# Generate MANIFEST file

auto_manifest();


# Generate Makefile and META.yml files

WriteAll;


# Generate the LICENSE file

auto_license();


# Generate the README and manpage files from the POD docs

auto_doc();



#--------- UTILS --------------------------------------------------------------#


sub auto_doc {
   print "*** Building doc...\n";
   # Generate scripts/copyrighter.pod
   my @args = ($^X, '-Ilib', 'scripts/copyrighter', '--podfile');
   system(@args) == 0 or die "System call to '@args' failed:\n$?\n";
   my $pod = 'scripts/copyrighter.pod';
   my $man_dir = 'man';
   if (not -d $man_dir) {
      mkdir $man_dir or die "Could not write folder $man_dir:\n$!\n";
   }
   my $clean   = 1;
   readme_from $pod, $clean, 'txt', 'README';
   readme_from $pod, $clean, 'htm', 'README.htm';
   readme_from $pod, $clean, 'man', "$man_dir/copyrighter.1";
   return 1;
}
