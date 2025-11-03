#!/usr/bin/env Rscript

cat("=== SCRIPT 1: TAXONOMY F1-SCORE ANALYSIS ===\n\n")

# Load required packages
if (!require(dplyr)) install.packages("dplyr", repos="http://cran.r-project.org")
if (!require(tidyr)) install.packages("tidyr", repos="http://cran.r-project.org")
library(dplyr)
library(tidyr)

# Set paths
project_path <- "/mnt/c/users/Aspasia/Desktop/Thesis ΕΚΕΤΑ/qiime2-dada2-comparison"
input_path <- file.path(project_path, "processed_data/f1score_analysis")
output_path <- file.path(project_path, "processed_data/comprehensive_analysis")

# Create output directory
dir.create(output_path, recursive = TRUE, showWarnings = FALSE)

# Load taxonomy data - USING THE FIXED DADA2 FILE
cat("Loading taxonomy files...\n")
qiime2_tax <- read.delim(file.path(input_path, "qiime2_taxonomy.tsv"), sep = "\t")
dada2_tax <- read.delim(file.path(input_path, "dada2_taxonomy_md5.tsv"), sep = "\t")
ground_truth_tax <- read.delim(file.path(input_path, "ground_truth_taxonomy.tsv"), sep = "\t")

cat("Data dimensions:\n")
cat("- QIIME2:", nrow(qiime2_tax), "features\n")
cat("- DADA2:", nrow(dada2_tax), "features\n")
cat("- Ground truth:", nrow(ground_truth_tax), "features\n")

# Taxonomy parsing function
parse_taxonomy_simple <- function(tax_df) {
  result <- tax_df %>%
    separate(Taxon, into = c("Kingdom", "Phylum", "Class", "Order", "Family", "Genus", "Species"), 
             sep = ";", fill = "right", extra = "merge") %>%
    mutate(across(everything(), ~gsub(".__", "", .))) %>%
    mutate(across(everything(), ~ifelse(. == "" | is.na(.), "Unassigned", .)))
  return(result)
}

cat("Parsing taxonomy...\n")
qiime2_parsed <- parse_taxonomy_simple(qiime2_tax)
dada2_parsed <- parse_taxonomy_simple(dada2_tax)
ground_truth_parsed <- parse_taxonomy_simple(ground_truth_tax)

# F1-score calculation function
calculate_comprehensive_metrics <- function(method_df, truth_df, level) {
  common_features <- intersect(method_df$Feature.ID, truth_df$Feature.ID)
  
  if (length(common_features) == 0) {
    return(data.frame(
      Level = level,
      Precision = 0,
      Recall = 0,
      F1_Score = 0,
      Accuracy = 0,
      Common_Features = 0
    ))
  }
  
  method_sub <- method_df[method_df$Feature.ID %in% common_features, ]
  truth_sub <- truth_df[truth_df$Feature.ID %in% common_features, ]
  
  # Ensure same order
  method_sub <- method_sub[match(common_features, method_sub$Feature.ID), ]
  truth_sub <- truth_sub[match(common_features, truth_sub$Feature.ID), ]
  
  # Calculate metrics
  correct_assignment <- method_sub[[level]] == truth_sub[[level]]
  method_assigned <- method_sub[[level]] != "Unassigned"
  truth_assigned <- truth_sub[[level]] != "Unassigned"
  
  TP <- sum(method_assigned & truth_assigned & correct_assignment)
  FP <- sum(method_assigned & (!truth_assigned | !correct_assignment))
  FN <- sum(truth_assigned & (!method_assigned | !correct_assignment))
  TN <- sum(!method_assigned & !truth_assigned)
  
  precision <- ifelse((TP + FP) > 0, TP / (TP + FP), 0)
  recall <- ifelse((TP + FN) > 0, TP / (TP + FN), 0)
  f1_score <- ifelse((precision + recall) > 0, 2 * (precision * recall) / (precision + recall), 0)
  accuracy <- (TP + TN) / (TP + TN + FP + FN)
  
  return(data.frame(
    Level = level,
    Precision = round(precision, 4),
    Recall = round(recall, 4),
    F1_Score = round(f1_score, 4),
    Accuracy = round(accuracy, 4),
    Common_Features = length(common_features)
  ))
}

# Analyze all taxonomic levels
tax_levels <- c("Kingdom", "Phylum", "Class", "Order", "Family", "Genus", "Species")

cat("Calculating F1-scores...\n")
qiime2_metrics <- do.call(rbind, lapply(tax_levels, function(lvl) {
  result <- calculate_comprehensive_metrics(qiime2_parsed, ground_truth_parsed, lvl)
  result$Method <- "QIIME2"
  return(result)
}))

dada2_metrics <- do.call(rbind, lapply(tax_levels, function(lvl) {
  result <- calculate_comprehensive_metrics(dada2_parsed, ground_truth_parsed, lvl)
  result$Method <- "DADA2"
  return(result)
}))

taxonomy_results <- rbind(qiime2_metrics, dada2_metrics)
taxonomy_results <- taxonomy_results[, c("Method", "Level", "Precision", "Recall", "F1_Score", "Accuracy", "Common_Features")]

# Save results
write.table(taxonomy_results, file.path(output_path, "01_taxonomy_classification_metrics.tsv"), 
            sep = "\t", row.names = FALSE, quote = FALSE)

# Create summary
taxonomy_summary <- taxonomy_results %>%
  group_by(Method) %>%
  summarise(
    Avg_F1_Score = round(mean(F1_Score, na.rm = TRUE), 4),
    Avg_Precision = round(mean(Precision, na.rm = TRUE), 4),
    Avg_Recall = round(mean(Recall, na.rm = TRUE), 4)
  )

write.table(taxonomy_summary, file.path(output_path, "01_taxonomy_summary.tsv"), 
            sep = "\t", row.names = FALSE, quote = FALSE)

# Print results
cat("\n=== TAXONOMY F1-SCORE RESULTS ===\n")
print(taxonomy_results)

cat("\n=== SUMMARY ===\n")
print(taxonomy_summary)

cat("\n✓ Script 1 completed successfully!\n")
cat("✓ Files saved in:", output_path, "\n")
cat("✓ Output files:\n")
cat("  - 01_taxonomy_classification_metrics.tsv\n")
cat("  - 01_taxonomy_summary.tsv\n\n")