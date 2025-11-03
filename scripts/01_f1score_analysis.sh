#!/bin/bash

echo "=== F1-Score Analysis: Taxonomy Classification Performance ==="

PROJECT_DIR="/mnt/c/Users/Aspasia/Desktop/Thesis ΕΚΕΤΑ/qiime2-dada2-comparison"
OUTPUT_DIR="$PROJECT_DIR/processed_data/f1score_analysis"

mkdir -p "$OUTPUT_DIR"

# Export taxonomy files to TSV
echo "Exporting taxonomy files..."

qiime tools export \
  --input-path "$PROJECT_DIR/data/qiime2_data/qiime2_taxonomy.qza" \
  --output-path "$OUTPUT_DIR"
mv "$OUTPUT_DIR/taxonomy.tsv" "$OUTPUT_DIR/qiime2_taxonomy.tsv"

qiime tools export \
  --input-path "$PROJECT_DIR/data/dada2_data/dada2_taxonomy.qza" \
  --output-path "$OUTPUT_DIR"
mv "$OUTPUT_DIR/taxonomy.tsv" "$OUTPUT_DIR/dada2_taxonomy.tsv"

qiime tools export \
  --input-path "$PROJECT_DIR/data/raw_data/taxonomy.qza" \
  --output-path "$OUTPUT_DIR"
mv "$OUTPUT_DIR/taxonomy.tsv" "$OUTPUT_DIR/ground_truth_taxonomy.tsv"

echo "Running F1-score analysis..."
Rscript "$PROJECT_DIR/scripts/f1score_analysis.R"

echo "F1-score analysis complete! TSV results in: $OUTPUT_DIR"