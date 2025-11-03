#!/usr/bin/env Rscript

cat("=== SCRIPT 2: TAXONOMIC COMPOSITION COMPARISON ===\n\n")

# Load required packages
suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(tidyr)
  library(forcats)
})

# Set paths
project_path <- "/mnt/c/users/Aspasia/Desktop/Thesis ΕΚΕΤΑ/qiime2-dada2-comparison"
input_path <- file.path(project_path, "processed_data/f1score_analysis")
output_path <- file.path(project_path, "processed_data/comprehensive_analysis")

# Create output directory
dir.create(output_path, recursive = TRUE, showWarnings = FALSE)

cat("Loading taxonomy files...\n")

# Load taxonomy data
qiime2_tax <- read.delim(file.path(input_path, "qiime2_taxonomy.tsv"), sep = "\t")
dada2_tax <- read.delim(file.path(input_path, "dada2_taxonomy_md5.tsv"), sep = "\t")

cat("Data dimensions:\n")
cat("- QIIME2:", nrow(qiime2_tax), "features\n")
cat("- DADA2:", nrow(dada2_tax), "features\n")

# Taxonomy parsing function
parse_taxonomy_for_composition <- function(tax_df) {
  result <- tax_df %>%
    separate(Taxon, into = c("Kingdom", "Phylum", "Class", "Order", "Family", "Genus", "Species"), 
             sep = ";", fill = "right", extra = "merge") %>%
    mutate(across(everything(), ~gsub(".__", "", .))) %>%
    mutate(across(everything(), ~ifelse(. == "" | is.na(.), "Unassigned", .)))
  return(result)
}

cat("Parsing taxonomy for composition analysis...\n")
qiime2_parsed <- parse_taxonomy_for_composition(qiime2_tax)
dada2_parsed <- parse_taxonomy_for_composition(dada2_tax)

# Function to calculate taxonomic composition
calculate_taxonomic_composition <- function(parsed_tax, method_name) {
  tax_levels <- c("Phylum", "Class", "Order", "Family", "Genus")
  
  composition_list <- list()
  
  for (level in tax_levels) {
    comp <- parsed_tax %>%
      count(.data[[level]]) %>%
      mutate(
        Proportion = n / sum(n),
        Level = level,
        Method = method_name
      ) %>%
      rename(Taxon = all_of(level)) %>%
      select(Method, Level, Taxon, Count = n, Proportion)
    
    composition_list[[level]] <- comp
  }
  
  return(bind_rows(composition_list))
}

cat("Calculating taxonomic composition...\n")
qiime2_composition <- calculate_taxonomic_composition(qiime2_parsed, "QIIME2")
dada2_composition <- calculate_taxonomic_composition(dada2_parsed, "DADA2")

# Combine results
combined_composition <- bind_rows(qiime2_composition, dada2_composition)

# Save composition results
write.table(combined_composition, 
            file.path(output_path, "02_taxonomic_composition.tsv"), 
            sep = "\t", row.names = FALSE, quote = FALSE)

# Calculate top taxa for visualization
get_top_taxa <- function(composition_data, level, n_top = 10) {
  composition_data %>%
    filter(Level == level) %>%
    group_by(Taxon) %>%
    summarise(Total_Count = sum(Count)) %>%
    arrange(desc(Total_Count)) %>%
    head(n_top) %>%
    pull(Taxon)
}

# Create visualization function
create_composition_plot <- function(level, n_top = 10) {
  top_taxa <- get_top_taxa(combined_composition, level, n_top)
  
  plot_data <- combined_composition %>%
    filter(Level == level) %>%
    mutate(Taxon = ifelse(Taxon %in% top_taxa, Taxon, "Other")) %>%
    group_by(Method, Taxon) %>%
    summarise(Count = sum(Count), .groups = "drop") %>%
    group_by(Method) %>%
    mutate(Proportion = Count / sum(Count)) %>%
    ungroup()
  
  ggplot(plot_data, aes(x = Method, y = Proportion, fill = fct_reorder(Taxon, Proportion, .desc = TRUE))) +
    geom_bar(stat = "identity", position = "fill") +
    scale_fill_brewer(palette = "Set3", name = level) +
    labs(
      title = paste("Taxonomic Composition:", level),
      y = "Proportion",
      x = "Method"
    ) +
    theme_minimal() +
    theme(legend.position = "right")
}

cat("Creating visualizations...\n")

# Create composition plots for different levels
p_phylum <- create_composition_plot("Phylum")
p_class <- create_composition_plot("Class") 
p_order <- create_composition_plot("Order")
p_family <- create_composition_plot("Family")
p_genus <- create_composition_plot("Genus")

# Save individual plots
ggsave(file.path(output_path, "02_composition_phylum.png"), p_phylum, width = 10, height = 6, dpi = 300)
ggsave(file.path(output_path, "02_composition_class.png"), p_class, width = 10, height = 6, dpi = 300)
ggsave(file.path(output_path, "02_composition_order.png"), p_order, width = 10, height = 6, dpi = 300)
ggsave(file.path(output_path, "02_composition_family.png"), p_family, width = 10, height = 6, dpi = 300)
ggsave(file.path(output_path, "02_composition_genus.png"), p_genus, width = 10, height = 6, dpi = 300)

# Calculate method differences
calculate_method_differences <- function() {
  tax_levels <- c("Phylum", "Class", "Order", "Family", "Genus")
  
  differences <- list()
  
  for (level in tax_levels) {
    qiime2_level <- qiime2_composition %>% filter(Level == level)
    dada2_level <- dada2_composition %>% filter(Level == level)
    
    # Merge to compare
    comparison <- full_join(
      qiime2_level %>% select(Taxon, QIIME2_Proportion = Proportion),
      dada2_level %>% select(Taxon, DADA2_Proportion = Proportion),
      by = "Taxon"
    ) %>%
      mutate(
        QIIME2_Proportion = ifelse(is.na(QIIME2_Proportion), 0, QIIME2_Proportion),
        DADA2_Proportion = ifelse(is.na(DADA2_Proportion), 0, DADA2_Proportion),
        Absolute_Difference = abs(QIIME2_Proportion - DADA2_Proportion),
        Level = level
      )
    
    differences[[level]] <- comparison
  }
  
  return(bind_rows(differences))
}

cat("Calculating method differences...\n")
method_differences <- calculate_method_differences()

# Save differences
write.table(method_differences, 
            file.path(output_path, "02_taxonomic_differences.tsv"), 
            sep = "\t", row.names = FALSE, quote = FALSE)

# Create summary statistics
summary_stats <- method_differences %>%
  group_by(Level) %>%
  summarise(
    Mean_Difference = round(mean(Absolute_Difference), 4),
    Max_Difference = round(max(Absolute_Difference), 4),
    Taxa_With_Differences = sum(Absolute_Difference > 0.01)
  )

write.table(summary_stats, 
            file.path(output_path, "02_taxonomic_differences_summary.tsv"), 
            sep = "\t", row.names = FALSE, quote = FALSE)

# Print results
cat("\n=== TAXONOMIC COMPOSITION SUMMARY ===\n")
cat("Total features analyzed:\n")
cat("- QIIME2:", nrow(qiime2_tax), "\n")
cat("- DADA2:", nrow(dada2_tax), "\n")

cat("\nTop 5 Phyla in QIIME2:\n")
qiime2_phylum <- qiime2_composition %>% 
  filter(Level == "Phylum") %>% 
  arrange(desc(Proportion)) %>% 
  head(5)
print(qiime2_phylum[, c("Taxon", "Proportion")])

cat("\nTop 5 Phyla in DADA2:\n")
dada2_phylum <- dada2_composition %>% 
  filter(Level == "Phylum") %>% 
  arrange(desc(Proportion)) %>% 
  head(5)
print(dada2_phylum[, c("Taxon", "Proportion")])

cat("\n=== METHOD DIFFERENCES SUMMARY ===\n")
print(summary_stats)

cat("\n✓ Script 2 completed successfully!\n")
cat("✓ Files saved in:", output_path, "\n")
cat("✓ Output files:\n")
cat("  - 02_taxonomic_composition.tsv\n")
cat("  - 02_taxonomic_differences.tsv\n")
cat("  - 02_taxonomic_differences_summary.tsv\n")
cat("  - Composition plots (PNG files)\n\n")