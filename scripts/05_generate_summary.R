#!/usr/bin/env Rscript
# Script: 05_generate_summary.R
# Purpose: Combine all results into a comprehensive summary

cat("Generating comprehensive summary...\n")

# Load individual results
jaccard <- read.csv("results/jaccard_analysis.csv")
alpha <- read.csv("results/alpha_diversity.csv")
fscore <- read.csv("results/fscore_analysis.csv")

# Combine all metrics
combined_results <- bind_rows(jaccard, alpha, fscore)

# Print comprehensive summary
cat("\n=== PIPELINE COMPARISON SUMMARY ===\n")
for (i in 1:nrow(combined_results)) {
  cat(sprintf("%-25s: %8.4f\n", combined_results$Metric[i], combined_results$Value[i]))
}

# Save combined results
write.csv(combined_results, "results/pipeline_comparison_metrics.csv", row.names = FALSE)

cat("\nSummary generation complete!\n")
cat("All results saved to 'results/' directory\n")