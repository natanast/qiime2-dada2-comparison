#!/usr/bin/env Rscript
# Script: 03_alpha_diversity.R
# Purpose: Calculate alpha diversity metrics and statistical tests

cat("Calculating alpha diversity...\n")

# Load required libraries
library(vegan)
library(dplyr)

# Load data
combined_tax <- read.csv("processed_data/combined_taxonomy.csv")
feature_table <- read.csv("processed_data/feature_table.csv", row.names = 1)

# Calculate Alpha Diversity (Shannon) ---------------------------------------
qiime2_features <- combined_tax %>% filter(Pipeline == "QIIME2") %>% pull(ID)
dada2_features <- combined_tax %>% filter(Pipeline == "DADA2") %>% pull(ID)

qiime2_table_filtered <- feature_table[rownames(feature_table) %in% qiime2_features, ]
dada2_table_filtered <- feature_table[rownames(feature_table) %in% dada2_features, ]

# Calculate Shannon Index for each sample
shannon_qiime2 <- diversity(t(qiime2_table_filtered), index = "shannon")
shannon_dada2 <- diversity(t(dada2_table_filtered), index = "shannon")

# Perform statistical test
wilcox_test_result <- wilcox.test(shannon_qiime2, shannon_dada2, paired = TRUE)

# Calculate additional diversity indices
simpson_qiime2 <- diversity(t(qiime2_table_filtered), index = "simpson")
simpson_dada2 <- diversity(t(dada2_table_filtered), index = "simpson")

# Save results
alpha_results <- data.frame(
  Metric = c("Mean_Shannon_QIIME2", "Mean_Shannon_DADA2", 
             "Mean_Simpson_QIIME2", "Mean_Simpson_DADA2",
             "Wilcoxon_p_value", "Wilcoxon_statistic"),
  Value = c(mean(shannon_qiime2), mean(shannon_dada2),
            mean(simpson_qiime2), mean(simpson_dada2),
            wilcox_test_result$p.value, wilcox_test_result$statistic)
)

write.csv(alpha_results, "results/alpha_diversity.csv", row.names = FALSE)

# Save detailed sample-level results
sample_results <- data.frame(
  Sample = colnames(feature_table),
  Shannon_QIIME2 = shannon_qiime2,
  Shannon_DADA2 = shannon_dada2,
  Simpson_QIIME2 = simpson_qiime2,
  Simpson_DADA2 = simpson_dada2
)
write.csv(sample_results, "results/alpha_diversity_by_sample.csv", row.names = FALSE)

cat("Alpha diversity analysis complete!\n")