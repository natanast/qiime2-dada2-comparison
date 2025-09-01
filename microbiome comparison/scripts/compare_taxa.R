# Load required libraries
library(vegan)
library(dplyr)
library(tidyr)

# 1. Load Prepared Data --------------------------------------------------------
combined_tax <- read.csv("processed_data/combined_taxonomy.csv")
feature_table <- read.csv("processed_data/feature_table.csv", row.names = 1) # Features are rows

# 2. Calculate Jaccard Index (Taxa Overlap) ------------------------------------
# Get the list of unique features (ASVs/OTUs) identified by each pipeline
qiime2_features <- combined_tax %>% filter(Pipeline == "QIIME2") %>% pull(ID)
dada2_features <- combined_tax %>% filter(Pipeline == "DADA2") %>% pull(ID)

# Calculate Jaccard Index: Intersection / Union
shared_features <- intersect(qiime2_features, dada2_features)
total_features <- union(qiime2_features, dada2_features)
jaccard_index <- length(shared_features) / length(total_features)

# 3. Calculate Alpha Diversity (Shannon) ---------------------------------------
# We use the same feature table but filter it for features assigned by each pipeline
qiime2_table_filtered <- feature_table[rownames(feature_table) %in% qiime2_features, ]
dada2_table_filtered <- feature_table[rownames(feature_table) %in% dada2_features, ]

# Calculate Shannon Index for each sample
shannon_qiime2 <- diversity(t(qiime2_table_filtered), index = "shannon")
shannon_dada2 <- diversity(t(dada2_table_filtered), index = "shannon")

# Perform a statistical test (paired Wilcoxon test)
wilcox_test_result <- wilcox.test(shannon_qiime2, shannon_dada2, paired = TRUE)

# 4. Calculate F-score (Precision & Recall) ------------------------------------
# This requires a 'ground truth'. Since we don't have a mock community,
# we will use the QIIME2 result as the reference to compare DADA2 against.
# This measures how well DADA2 replicates the QIIME2 result.

# Define "True Positives" (TP): Features assigned the SAME taxonomy by both pipelines
# Define "False Positives" (FP): Features assigned by DADA2 but not QIIME2, or with different taxonomy
# Define "False Negatives" (FN): Features assigned by QIIME2 but not DADA2, or with different taxonomy

# Merge taxonomy tables on Feature ID
comparison_df <- full_join(
  combined_tax %>% filter(Pipeline == "QIIME2") %>% select(ID, Taxonomy),
  combined_tax %>% filter(Pipeline == "DADA2") %>% select(ID, Taxonomy),
  by = "ID", suffix = c("_qiime2", "_dada2")
)

# Classify assignments
comparison_df <- comparison_df %>%
  mutate(
    Status = case_when(
      is.na(Taxonomy_qiime2) & !is.na(Taxonomy_dada2) ~ "FP", # DADA2 found something QIIME2 didn't
      !is.na(Taxonomy_qiime2) & is.na(Taxonomy_dada2) ~ "FN", # QIIME2 found something DADA2 didn't
      Taxonomy_qiime2 == Taxonomy_dada2 ~ "TP",               # Perfect agreement
      TRUE ~ "FP"                                             # Both assigned, but disagree (this is also an error)
    )
  )

# Count instances
tp <- sum(comparison_df$Status == "TP", na.rm = TRUE)
fp <- sum(comparison_df$Status == "FP", na.rm = TRUE)
fn <- sum(comparison_df$Status == "FN", na.rm = TRUE)

# Calculate Precision, Recall, F-Score
precision <- tp / (tp + fp)
recall <- tp / (tp + fn)
f_score <- 2 * ((precision * recall) / (precision + recall))

# 5. Save and Display Results --------------------------------------------------
results <- data.frame(
  Metric = c("Jaccard_Index", "Mean_Shannon_QIIME2", "Mean_Shannon_DADA2", "Wilcoxon_p_value", "Precision", "Recall", "F_Score"),
  Value = c(jaccard_index,
            mean(shannon_qiime2),
            mean(shannon_dada2),
            wilcox_test_result$p.value,
            precision,
            recall,
            f_score)
)

# Print results to console
print(results, row.names = FALSE)

# Save results
write.csv(results, "results/pipeline_comparison_metrics.csv", row.names = FALSE)
cat("\nAnalysis complete! Results saved to 'results/pipeline_comparison_metrics.csv'\n")