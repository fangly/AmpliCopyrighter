use inc::Module::Install;


# Package information

name     'Copyrighter';
all_from 'scripts/copyrighter';
license  'gpl3'; # Module::Install 1.04 does not parse the GPL version number

resources
   homepage   'http://github.com/fangly/AmpliCopyrighter';
   bugtracker 'http://github.com/fangly/AmpliCopyrighter/issues';
   repository 'git://github.com/fangly/AmpliCopyrighter.git';


# Dependencies for everyone

build_requires  'Test::More'                       =>  0;
requires        'Getopt::Euclid'                   => '0.3.4';
requires        'Method::Signatures'               =>  0;
requires        'Bio::SeqIO'                       =>  0;
requires        'Bio::DB::Fasta'                   =>  0; # from bioperl-live
requires        'Bio::DB::Taxonomy'                =>  0; # dev version of bioperl-live
requiresd       'Bio::Tools::Run::Alignment::Blat' =>  0; # from bioperl-run
requires        'Bio::Community'                   =>  0; # from Bio-Community
requires        'Statistics::Basic'                =>  0;


# Dependencies for developpers only

author_requires 'Module::Install';
author_requires 'Module::Install::AuthorRequires';
author_requires 'Module::Install::AutoLicense';
author_requires 'Module::Install::ReadmeFromPod' => 0.14;
author_requires 'Module::Install::AutoManifest';


# Install dependencies

auto_install;


# Extra scripts to install

install_script 'scripts/copyrighter';


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
