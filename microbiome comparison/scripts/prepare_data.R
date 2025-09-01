# Load required libraries
library(dplyr)
library(tidyr)

# 1. Load QIIME2 Data ----------------------------------------------------------
qiime2_tax <- read.delim("qiime2_export/taxonomy.tsv", sep = "\t")
qiime2_table <- read.delim("qiime2_export/feature-table.tsv", sep = "\t", skip = 1, row.names = 1)

# 2. Load DADA2 Data -----------------------------------------------------------
# The exact path might have a UUID folder inside 'dada2_export'. List files to find it.
dada2_export_path <- list.dirs("dada2_export", recursive = TRUE)
data_dir <- dada2_export_path[grepl("/data$", dada2_export_path)] # Find the /data subdirectory

dada2_tax <- read.delim(file.path(data_dir, "taxonomy.tsv"), sep = "\t")
# Note: DADA2 tutorial might not export a feature table in the same way.
# We will use the QIIME2 table for both for alpha diversity, as the underlying sequences are the same.

# 3. Standardize Format --------------------------------------------------------
# Rename columns for consistency and join
qiime2_tax_clean <- qiime2_tax %>%
  select(Feature.ID, Taxon) %>%
  rename(ID = Feature.ID, Taxonomy = Taxon) %>%
  mutate(Pipeline = "QIIME2")

dada2_tax_clean <- dada2_tax %>%
  select(Feature.ID, Taxon) %>%
  rename(ID = Feature.ID, Taxonomy = Taxon) %>%
  mutate(Pipeline = "DADA2")

# Combine into one dataframe for easy comparison
combined_tax <- bind_rows(qiime2_tax_clean, dada2_tax_clean)

# 4. Save Prepared Data --------------------------------------------------------
dir.create("processed_data", showWarnings = FALSE)
write.csv(combined_tax, "processed_data/combined_taxonomy.csv", row.names = FALSE)
write.csv(qiime2_table, "processed_data/feature_table.csv", row.names = TRUE)

cat("Data preparation complete!\n")
cat("- Combined taxonomy saved to: 'processed_data/combined_taxonomy.csv'\n")
cat("- Feature table saved to: 'processed_data/feature_table.csv'\n")