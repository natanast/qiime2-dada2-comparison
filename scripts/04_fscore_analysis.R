#!/usr/bin/env Rscript
# Script: 04_fscore_analysis.R
# Purpose: Calculate precision, recall, and F1-score using comprehensive methods

cat("Calculating precision, recall, and F1-score...\n")

# Load required libraries
library(dplyr)
library(tidyr)
library(caret)  # For confusion matrix and metrics

# Load data
combined_tax <- read.csv("processed_data/combined_taxonomy.csv")

# Calculate F-score (Precision & Recall) ------------------------------------

# Method 1: Using confusion matrix approach (as per GeeksforGeeks tutorial)
comparison_df <- full_join(
  combined_tax %>% filter(Pipeline == "QIIME2") %>% select(ID, Taxonomy),
  combined_tax %>% filter(Pipeline == "DADA2") %>% select(ID, Taxonomy),
  by = "ID", suffix = c("_qiime2", "_dada2")
)

# Create binary classification: 1 if taxonomy matches, 0 otherwise
comparison_df <- comparison_df %>%
  mutate(
    # Ground truth: QIIME2 assignments
    actual_class = ifelse(!is.na(Taxonomy_qiime2), 1, 0),
    # Prediction: DADA2 assignments (considering same taxonomy as correct)
    predicted_class = case_when(
      is.na(Taxonomy_dada2) ~ 0,  # No assignment
      !is.na(Taxonomy_qiime2) & Taxonomy_qiime2 == Taxonomy_dada2 ~ 1,  # Correct match
      TRUE ~ 0  # Different assignment
    )
  )

# Create confusion matrix
conf_matrix <- table(
  Actual = factor(comparison_df$actual_class, levels = c(0, 1)),
  Predicted = factor(comparison_df$predicted_class, levels = c(0, 1))
)

# Calculate metrics using confusion matrix
tp <- conf_matrix[2, 2]  # True Positives
fp <- conf_matrix[1, 2]  # False Positives
fn <- conf_matrix[2, 1]  # False Negatives
tn <- conf_matrix[1, 1]  # True Negatives

# Method 2: Manual calculation (as per original approach)
comparison_df_manual <- comparison_df %>%
  mutate(
    Status = case_when(
      is.na(Taxonomy_qiime2) & !is.na(Taxonomy_dada2) ~ "FP",
      !is.na(Taxonomy_qiime2) & is.na(Taxonomy_dada2) ~ "FN",
      Taxonomy_qiime2 == Taxonomy_dada2 ~ "TP",
      TRUE ~ "FP"
    )
  )

tp_manual <- sum(comparison_df_manual$Status == "TP", na.rm = TRUE)
fp_manual <- sum(comparison_df_manual$Status == "FP", na.rm = TRUE)
fn_manual <- sum(comparison_df_manual$Status == "FN", na.rm = TRUE)

# Calculate metrics using both methods
precision_cm <- tp / (tp + fp)
recall_cm <- tp / (tp + fn)
f1_cm <- 2 * ((precision_cm * recall_cm) / (precision_cm + recall_cm))

precision_manual <- tp_manual / (tp_manual + fp_manual)
recall_manual <- tp_manual / (tp_manual + fn_manual)
f1_manual <- 2 * ((precision_manual * recall_manual) / (precision_manual + recall_manual))

# Method 3: Using caret package for additional metrics
if (nrow(comparison_df) > 0) {
  cm_caret <- confusionMatrix(
    factor(comparison_df$predicted_class, levels = c(0, 1)),
    factor(comparison_df$actual_class, levels = c(0, 1))
  )
  
  precision_caret <- cm_caret$byClass["Precision"]
  recall_caret <- cm_caret$byClass["Recall"]
  f1_caret <- cm_caret$byClass["F1"]
} else {
  precision_caret <- recall_caret <- f1_caret <- NA
}

# Save comprehensive results
fscore_results <- data.frame(
  Method = c("Confusion_Matrix", "Manual_Calculation", "Caret_Package"),
  True_Positives = c(tp, tp_manual, NA),
  False_Positives = c(fp, fp_manual, NA),
  False_Negatives = c(fn, fn_manual, NA),
  True_Negatives = c(tn, NA, NA),
  Precision = c(precision_cm, precision_manual, precision_caret),
  Recall = c(recall_cm, recall_manual, recall_caret),
  F1_Score = c(f1_cm, f1_manual, f1_caret),
  Accuracy = c((tp + tn) / (tp + tn + fp + fn), NA, cm_caret$overall["Accuracy"])
)

write.csv(fscore_results, "results/fscore_analysis_comprehensive.csv", row.names = FALSE)

# Save simplified version (using manual method as primary)
primary_results <- data.frame(
  Metric = c("True_Positives", "False_Positives", "False_Negatives", 
             "Precision", "Recall", "F1_Score", "Accuracy"),
  Value = c(tp_manual, fp_manual, fn_manual, 
           precision_manual, recall_manual, f1_manual,
           (tp_manual + tn) / (tp_manual + tn + fp_manual + fn_manual))
)

write.csv(primary_results, "results/fscore_analysis.csv", row.names = FALSE)

# Save detailed comparison
write.csv(comparison_df, "results/taxonomy_comparison_detailed.csv", row.names = FALSE)

# Print summary
cat("\n=== F-SCORE ANALYSIS RESULTS ===\n")
cat("Primary Method (Manual Calculation):\n")
cat(sprintf("Precision:  %.4f\n", precision_manual))
cat(sprintf("Recall:     %.4f\n", recall_manual))
cat(sprintf("F1-Score:   %.4f\n", f1_manual))
cat(sprintf("Accuracy:   %.4f\n", primary_results$Value[primary_results$Metric == "Accuracy"]))
cat(sprintf("TP/FP/FN:   %d/%d/%d\n", tp_manual, fp_manual, fn_manual))

cat("\nF-score analysis complete!\n")