#! perl

use strict;
use warnings;
use Test::More;
use t::TestUtils;


my ($in_file, $out_file);


# Simply checking that the options work and that Copyrighter does not crash
# Should check the content of the output files someday

$in_file = data('otu_table.generic');
ok run_copyrighter(['-i', $in_file]);
ok -e 'otu_copyrighted.txt';
unlink 'otu_copyrighted.txt';


$in_file  = data('otu_table.qiime');
$out_file = 'out_file.qiime';
ok run_copyrighter(['-i', $in_file, '-o', $out_file]);
ok -e $out_file;
unlink $out_file;


$in_file  = data('otu_table.qiime');
$out_file = 'out_file.qiime';
ok run_copyrighter(['-i', $in_file, '-o', $out_file, '-v']);
ok -e $out_file;
unlink $out_file;


done_testing();

