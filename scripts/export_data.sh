#!/bin/bash

# Script to export data from QIIME2 .qza and .qzv files for comparison
echo "Starting data export..."

# Define your main project directory (update this path!)
PROJECT_DIR=".."
DATA_DIR="$PROJECT_DIR/data"

# Navigate to the project directory
cd "$PROJECT_DIR"

echo "Current directory: $(pwd)"
echo "Data directory contents:"
ls -la "$DATA_DIR/qiime2_data/" || echo "Cannot access qiime2_data"
ls -la "$DATA_DIR/dada2_data/" || echo "Cannot access dada2_data"

# Create export directories if they don't exist
mkdir -p "$DATA_DIR/qiime2_data/qiime2_exported_taxonomy"
mkdir -p "$DATA_DIR/dada2_data/dada2_exported_taxonomy"

# --- Export QIIME2 Data ---
echo "Exporting QIIME2 taxonomy data..."
qiime tools export \
  --input-path "$DATA_DIR/qiime2_data/qiime2_taxonomy.qza" \
  --output-path "$DATA_DIR/qiime2_data/qiime2_exported_taxonomy"

echo "QIIME2 export complete!"

# --- Export DADA2 Data ---
echo "Exporting DADA2 taxonomy data..."
# Unzip the .qzv visualization file to access the data
unzip -q "$DATA_DIR/dada2_data/dada2_taxonomy.qzv" -d "$DATA_DIR/dada2_data/dada2_exported_taxonomy"

echo "Export complete!"
echo "- QIIME2 files in: $DATA_DIR/qiime2_data/qiime2_exported_taxonomy"
echo "- DADA2 files in: $DATA_DIR/dada2_data/dada2_exported_taxonomy"