# Load required libraries
library(dplyr)
library(tidyr)

# Define paths based on your new structure
project_dir <- "/mnt/c/Users/Aspasia/Desktop/Thesis ΕΚΕΤΑ/qiime2-dada2-comparison"
data_dir <- file.path(project_dir, "data")

# 1. Load QIIME2 Data ----------------------------------------------------------
qiime2_tax_path <- file.path(data_dir, "qiime2_data/qiime2_exported_taxonomy/taxonomy.tsv")

if (!file.exists(qiime2_tax_path)) {
  stop("QIIME2 taxonomy file not found: ", qiime2_tax_path)
}

qiime2_tax <- read.delim(qiime2_tax_path, sep = "\t")

# Try to load QIIME2 feature table if it exists
qiime2_table_path <- file.path(data_dir, "qiime2_data/qiime2_exported_taxonomy/feature-table.tsv")
if (file.exists(qiime2_table_path)) {
  qiime2_table <- read.delim(qiime2_table_path, sep = "\t", skip = 1, row.names = 1)
  has_feature_table <- TRUE
} else {
  cat("Note: QIIME2 feature table not found, only processing taxonomy data\n")
  has_feature_table <- FALSE
}

# 2. Load DADA2 Data -----------------------------------------------------------
# The DADA2 export creates a UUID folder structure, so we need to find the data directory
dada2_export_path <- file.path(data_dir, "dada2_data/dada2_exported_taxonomy")
dada2_subdirs <- list.dirs(dada2_export_path, recursive = TRUE)
data_subdir <- dada2_subdirs[grepl("/data$", dada2_subdirs)] # Find the /data subdirectory

if (length(data_subdir) == 0) {
  stop("Could not find data directory in DADA2 export. Please check the export structure.")
}

dada2_tax_path <- file.path(data_subdir, "taxonomy.tsv")
if (!file.exists(dada2_tax_path)) {
  stop("DADA2 taxonomy file not found: ", dada2_tax_path)
}

dada2_tax <- read.delim(dada2_tax_path, sep = "\t")

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
processed_dir <- file.path(project_dir, "processed_data")
dir.create(processed_dir, showWarnings = FALSE)

write.csv(combined_tax, file.path(processed_dir, "combined_taxonomy.csv"), row.names = FALSE)

if (has_feature_table) {
  write.csv(qiime2_table, file.path(processed_dir, "feature_table.csv"), row.names = TRUE)
}

cat("Data preparation complete!\n")
cat("- Combined taxonomy saved to: '", file.path(processed_dir, "combined_taxonomy.csv"), "'\n", sep = "")
cat("- Number of QIIME2 features:", nrow(qiime2_tax_clean), "\n")
cat("- Number of DADA2 features:", nrow(dada2_tax_clean), "\n")
if (has_feature_table) {
  cat("- Feature table saved to: '", file.path(processed_dir, "feature_table.csv"), "'\n", sep = "")
} else {
  cat("- No feature table available (taxonomy only)\n")
}