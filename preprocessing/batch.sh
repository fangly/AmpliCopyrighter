#! /bin/bash

# Run all the preprocessing steps and populate the ../data/ folder with the results

FINISHED_ONLY=1

# Patch known errors in IMG metadata
cp ./data/img_metadata.txt ./tmp/img_metadata_patched.txt
patch ./tmp/img_metadata_patched.txt ./data/img_metadata.patch

echo "Running img_gg_matcher..."
time ./img_gg_matcher -c ./data/img_to_gg.txt -i ./tmp/img_metadata_patched.txt -s ./data/gg_12_10.fasta -n ./data/gg_named_isolates.txt -r ./data/16S_from_img_all_genomes.fa 1> ./tmp/img_to_gg_expanded.txt 2> log_matcher.txt

echo "Running data_combiner..."
time ./data_combiner -i ./tmp/img_metadata_patched.txt -g ./data/gg_12_10_taxonomy.txt -c ./tmp/img_to_gg_expanded.txt -f $FINISHED_ONLY -s 1 1> ./tmp/img_metadata_combined.txt 2> log_combiner.txt

echo "Running trait_by_genome..."
time ./trait_by_genome -i ./tmp/img_metadata_combined.txt 1> ../data/201210/trait_per_genome.txt 2> log_per_genome.txt

echo "Running trait_by_clade..."
time ./trait_by_clade_weigthed -i ./tmp/img_metadata_combined.txt -t '16S Count' -a 0 1> ../data/201210/16S_counts.txt 2> log_clade_average.txt

echo "Running trait_by_clade advanced..."
time ./trait_by_clade_weigthed -i ./tmp/img_metadata_combined.txt -t '16S Count' -a 1 1> ../data/201210/16S_counts_advanced.txt 2> log_per_clade.txt

