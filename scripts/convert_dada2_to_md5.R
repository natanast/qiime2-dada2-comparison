#!/usr/bin/env Rscript

cat("=== CONVERTING DADA2 FEATURE.IDs TO MD5 HASHES ===\n\n")

library(dplyr)
library(digest)  # For MD5 hashing

# Set paths
project_path <- "/mnt/c/users/Aspasia/Desktop/Thesis ΕΚΕΤΑ/qiime2-dada2-comparison"
input_path <- file.path(project_path, "processed_data/f1score_analysis")

# Load the fixed DADA2 taxonomy file
cat("Loading DADA2 taxonomy file...\n")
dada2_tax <- read.delim(file.path(input_path, "dada2_taxonomy_fixed.tsv"), sep = "\t")

cat("Original DADA2 structure:\n")
cat("Rows:", nrow(dada2_tax), "\n")
cat("First 3 Feature.IDs (sequences):\n")
print(head(dada2_tax$Feature.ID, 3))

# Convert DNA sequences to MD5 hashes
cat("\nConverting DNA sequences to MD5 hashes...\n")
dada2_tax$Feature.ID <- sapply(dada2_tax$Feature.ID, function(seq) {
  digest(seq, algo = "md5", serialize = FALSE)
})

cat("After MD5 conversion:\n")
cat("First 3 Feature.IDs (MD5 hashes):\n")
print(head(dada2_tax$Feature.ID, 3))

# Save the updated DADA2 taxonomy file
output_file <- file.path(input_path, "dada2_taxonomy_md5.tsv")
write.table(dada2_tax, output_file, sep = "\t", row.names = FALSE, quote = FALSE)

cat("\n✅ Converted DADA2 taxonomy file saved to:", output_file, "\n")
cat("Final dimensions:", nrow(dada2_tax), "rows x", ncol(dada2_tax), "columns\n")

# Verify the conversion by checking overlap
cat("\n=== VERIFICATION ===\n")
qiime2_tax <- read.delim(file.path(input_path, "qiime2_taxonomy.tsv"), sep = "\t")
ground_truth_tax <- read.delim(file.path(input_path, "ground_truth_taxonomy.tsv"), sep = "\t")

cat("QIIME2 vs DADA2 (MD5) overlap:", length(intersect(qiime2_tax$Feature.ID, dada2_tax$Feature.ID)), "features\n")
cat("Ground Truth vs DADA2 (MD5) overlap:", length(intersect(ground_truth_tax$Feature.ID, dada2_tax$Feature.ID)), "features\n")