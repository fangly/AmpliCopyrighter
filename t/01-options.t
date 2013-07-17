#! perl

use strict;
use warnings;
use Test::More;
use t::TestUtils;


my ($in_file, $data_file, $total_file, $out_file, $out_file_2, $out_file_3);


# Simply checking that the options work and that Copyrighter does not crash
# Should check the content of the output files someday

use Env qw($COPYRIGHTER_DB);
$COPYRIGHTER_DB = 'data/201210/ssu_img40_gg201210_merged.txt';

$in_file = data('otu_table.generic');
ok run_copyrighter(['-i', $in_file]);
ok -e 'out_copyrighted.txt';
unlink 'out_copyrighted.txt';


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


$in_file   = data('otu_table.qiime');
$data_file = data('16S_data.txt');
$out_file  = 'out_file.qiime';
ok run_copyrighter(['-i', $in_file, '-o', $out_file, '-d', $data_file]);
ok -e $out_file;
unlink $out_file;

$in_file    = data('otu_table.qiime');
$data_file  = data('16S_data.txt');
$total_file = data('total_abundance.tsv');
$out_file   = 'out_file.qiime';
$out_file_2 = 'out_file_total.tsv';
$out_file_3 = 'out_file_combined.qiime';
ok run_copyrighter(['-i', $in_file, '-o', $out_file, '-d', $data_file, '-t', $total_file]);
ok -e $out_file;
ok -e $out_file_2;
ok -e $out_file_3;
unlink $out_file;
unlink $out_file_2;
unlink $out_file_3;

# TEST $ENV{COPYRIGHTER_DB}

done_testing();

