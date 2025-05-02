##### Activation of conda environment #####
conda activate qiime2-amplicon-2023.9



##### Import data #####
qiime tools import \
--type 'SampleData[PairedEndSequencesWithQuality]' \
--input-path ManifestFile.tsv \
--output-path demux.qza \
--input-format PairedEndFastqManifestPhred33V2



##### Primer trimming #####
qiime cutadapt trim-paired \
--i-demultiplexed-sequences demux.qza \
--o-trimmed-sequences trimmed.qza \
--p-front-f GTGCCAGCMGCCGCGGTAA \
--p-front-r GGACTACHVGGGTWTCTAAT \
--p-error-rate 0.1 \
--p-cores 48



##### Visudalization of results #####
qiime demux summarize \
--i-data trimmed.qza \
--o-visualization trimmed.qzv



##### ASV generation with DADA2 #####
qiime dada2 denoise-paired \
--quiet \
--p-n-threads 48 \
--p-trim-left-f 0 \
--p-trim-left-r 0 \
--p-trunc-len-f 270 \
--p-trunc-len-r 250 \
--i-demultiplexed-seqs trimmed.qza \
--o-table table.qza \
--o-representative-sequences rep-seqs.qza \
--o-denoising-stats stats-dada2.qza
# For dark-induced bleaching samples:
# --p-trunc-len-f 260
# --p-trunc-len-r 220

# Summerize results
qiime metadata tabulate \
--m-input-file stats-dada2.qza \
--o-visualization stats-dada2.qzv
qiime feature-table summarize \
--i-table table.qza \
--o-visualization table.qzv \
--m-sample-metadata-file Metadata.tsv



##### Feature classification #####
qiime feature-classifier classify-sklearn \
--p-n-jobs 48 \
--i-classifier /path/to/silva-138-99-515F-806RB-classifier.qza \
--i-reads rep-seqs.qza \
--o-classification taxonomy.qza

qiime metadata tabulate \
--m-input-file taxonomy.qza \
--o-visualization taxonomy.qzv



##### Molecular phylogenetic analysis #####
qiime phylogeny align-to-tree-mafft-fasttree \
--i-sequences rep-seqs.qza \
--o-alignment aligned-rep-seqs.qza \
--o-masked-alignment masked-aligned-rep-seqs.qza \
--o-tree unrooted-tree.qza \
--o-rooted-tree rooted-tree.qza



##### Filtering of non-bacterial ASVs #####
# Extract non-bacterial or unassigned ASVs 
qiime tools export --input-path taxonomy.qza --output-path taxonomy
cd /path/to/taxonomy/
grep -v d__Bacteria taxonomy.tsv > taxonomy_non-bacteria.tsv
grep Chloroplast taxonomy.tsv >> taxonomy_non-bacteria.tsv
grep Mitochondria taxonomy.tsv >> taxonomy_non-bacteria.tsv

# Filtering of ASVs
cd /path/to/filter/
awk '{print $1}' /path/to/taxonomy/taxonomy_non-bacteria.tsv > filter-feature.txt  # Manually delete the header of filter-feature.txt
qiime feature-table filter-features \
--i-table ../table.qza \
--m-metadata-file filter-feature.txt \
--p-exclude-ids \
--o-filtered-table filtered_table.qza

# Summerize data
qiime feature-table summarize \
--i-table filtered_table.qza \
--o-visualization filtered_table.qzv \
--m-sample-metadata-file ../Metadata.tsv



##### Taxonomy bar plot #####
qiime taxa barplot \
--i-table filtered_table.qza \
--i-taxonomy ../taxonomy.qza \
--m-metadata-file ../Metadata.tsv \
--o-visualization taxa-bar-plots.qzv



##### Rarefaction curve #####
qiime diversity alpha-rarefaction \
--i-table filtered_table.qza \
--i-phylogeny /path/to/rooted-tree.qza \
--p-max-depth 15557 \
--m-metadata-file /path/to/Metadata.tsv \
--o-visualization alpha-rarefaction.qzv



##### Diversity analysis #####
# Exclude seawater samples
# This process was not carried out for dark-induced bleaching samples
cd /path/to/filter-water/
qiime feature-table filter-samples \
--i-table /path/to/filtered_table.qza \
--m-metadata-file filter-sample.txt \
--p-exclude-ids \
--o-filtered-table filtered_table_no-seawater.qza

# Alpha and beta diversity core metrics
qiime diversity core-metrics-phylogenetic \
--i-phylogeny /path/to/rooted-tree.qza \
--i-table filtered_table_no-seawater.qza \
--p-sampling-depth 15557 \
--m-metadata-file Metadata2.tsv \
--output-dir core-metrics-results

# Alpha diversity
qiime diversity alpha-group-significance \
--i-alpha-diversity core-metrics-results/observed_features_vector.qza \
--m-metadata-file Metadata2.tsv \
--o-visualization core-metrics-results/observed_features-groups-significance.qzv

qiime diversity alpha-group-significance \
--i-alpha-diversity core-metrics-results/shannon_vector.qza \
--m-metadata-file Metadata2.tsv \
--o-visualization core-metrics-results/shannon-groups-significance.qzv

qiime diversity alpha-group-significance \
--i-alpha-diversity core-metrics-results/faith_pd_vector.qza \
--m-metadata-file Metadata2.tsv \
--o-visualization core-metrics-results/faith-pd-group-significance.qzv

# Beta diversity
qiime tools export \
--input-path core-metrics-results/bray_curtis_pcoa_results.qza  \
--output-path core-metrics-results/bray_curtis_pcoa_results
qiime tools export \
--input-path bray_curtis_distance_matrix.qza \
--output-path bray_curtis_exported  # This directory contains the input file of PERMANOVA



##### Preparation for LEfSe #####
# Extract feature table
qiime taxa collapse \
--i-table filtered_table_no-seawater \
--i-taxonomy /path/to/taxonomy.qza \
--p-level 6 \
--o-collapsed-table collapsed_table_l6.qza

# Convert to relative frequency
qiime feature-table relative-frequency \
--i-table collapsed_table_l6.qza \
--o-relative-frequency-table relative_frequency_table_l6.qza

# Export to text files
qiime tools export \
--input-path relative_frequency_table_l6.qza \
--output-path exported-feature-table_l6
cd /path/to/exported-feature-table_l6/
biom convert \
-i feature-table.biom \
-o exported-feature-table_l6.tsv \
--to-tsv \
--header-key taxonomy
