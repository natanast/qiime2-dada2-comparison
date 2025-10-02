#!/usr/bin/env Rscript
# Script: 02_jaccard_analysis.R
# Purpose: Calculate Jaccard index for feature overlap

cat("Calculating Jaccard index...\n")

# Load required libraries
library(dplyr)

# Load data (or source from previous script)
combined_tax <- read.csv("processed_data/combined_taxonomy.csv")

# Calculate Jaccard Index (Taxa Overlap) ------------------------------------
qiime2_features <- combined_tax %>% filter(Pipeline == "QIIME2") %>% pull(ID)
dada2_features <- combined_tax %>% filter(Pipeline == "DADA2") %>% pull(ID)

shared_features <- intersect(qiime2_features, dada2_features)
total_features <- union(qiime2_features, dada2_features)
jaccard_index <- length(shared_features) / length(total_features)

# Save results
jaccard_results <- data.frame(
  Metric = c("Jaccard_Index", "Shared_Features", "Total_Features", "QIIME2_Features", "DADA2_Features"),
  Value = c(jaccard_index, length(shared_features), length(total_features), 
           length(qiime2_features), length(dada2_features))
)

write.csv(jaccard_results, "results/jaccard_analysis.csv", row.names = FALSE)

cat("Jaccard analysis complete!\n")
cat("- Jaccard Index:", round(jaccard_index, 4), "\n")
cat("- Shared features:", length(shared_features), "\n")
cat("- Total unique features:", length(total_features), "\n")