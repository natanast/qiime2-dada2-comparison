#!/usr/bin/env Rscript
# Script: 03_jaccard_analysis.R
# Purpose: Simple Jaccard index calculation

cat("JACCARD SIMILARITY ANALYSIS\n")
cat("===========================\n\n")

# Set paths
project_path <- "/mnt/c/users/Aspasia/Desktop/Thesis ΕΚΕΤΑ/qiime2-dada2-comparison"
input_path <- file.path(project_path, "processed_data/f1score_analysis")
output_path <- file.path(project_path, "processed_data/jaccard_analysis")

# Create output directory
dir.create(output_path, recursive = TRUE, showWarnings = FALSE)

# Load data
cat("Loading data...\n")
qiime2_tax <- read.delim(file.path(input_path, "qiime2_taxonomy.tsv"), sep = "\t")
dada2_tax <- read.delim(file.path(input_path, "dada2_taxonomy_md5.tsv"), sep = "\t")

# Extract feature IDs
qiime2_features <- qiime2_tax$Feature.ID
dada2_features <- dada2_tax$Feature.ID

# Calculate overlap
shared_features <- intersect(qiime2_features, dada2_features)
total_features <- union(qiime2_features, dada2_features)

# Calculate Jaccard index
jaccard_index <- length(shared_features) / length(total_features)

# Create results
results <- data.frame(
  Jaccard_Index = jaccard_index,
  Shared_Features = length(shared_features),
  Total_Features = length(total_features),
  QIIME2_Features = length(qiime2_features),
  DADA2_Features = length(dada2_features)
)

# Save results
write.table(results, file.path(output_path, "jaccard_results.tsv"), 
            sep = "\t", row.names = FALSE, quote = FALSE)

# Print results
cat("\nRESULTS:\n")
cat("Jaccard Index:", round(jaccard_index, 4), "\n")
cat("Shared features:", length(shared_features), "\n")
cat("Total features:", length(total_features), "\n")
cat("QIIME2 features:", length(qiime2_features), "\n")
cat("DADA2 features:", length(dada2_features), "\n")

cat("\nAnalysis complete! Results saved to jaccard_results.tsv\n")