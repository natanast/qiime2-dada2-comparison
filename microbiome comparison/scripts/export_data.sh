#!/bin/bash

# Script to export data from QIIME2 .qza and .qzv files for comparison
echo "Starting data export..."

# Define your main project directory (update this path!)
PROJECT_DIR="/mnt/c/Users/Aspasia/Desktop/Thesis ΕΚΕΤΑ/microbiome comparison"

# Navigate to the project directory
cd "$PROJECT_DIR"

# --- Export from QIIME2 Moving Pictures Tutorial ---
echo "Exporting QIIME2 data..."
# Export the QIIME2 taxonomy artifact (.qza) to a TSV file
qiime tools export \
  --input-path moving_pictures_tutorial/taxonomy.qza \
  --output-path qiime2_export

# Export the QIIME2 feature table artifact (.qza) to a BIOM file, then convert to TSV
qiime tools export \
  --input-path moving_pictures_tutorial/table.qza \
  --output-path qiime2_export
biom convert \
  -i qiime2_export/feature-table.biom \
  -o qiime2_export/feature-table.tsv \
  --to-tsv

# --- Export from DADA2 Tutorial ---
echo "Exporting DADA2 data..."
# The DADA2 output is a .qzv visualization file. We need to unzip it to get the data.
unzip -q dada2_tutorial/taxonomy.qzv -d dada2_export

echo "Export complete! Files are in 'qiime2_export' and 'dada2_export' directories."