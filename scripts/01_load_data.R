#!/usr/bin/env Rscript
# Script: 01_load_data.R
# Purpose: Load and validate input data for all analyses

cat("Loading required libraries and data...\n")

# Load required libraries
library(vegan)
library(dplyr)
library(tidyr)

# Create results directory if it doesn't exist
if (!dir.exists("results")) {
  dir.create("results", recursive = TRUE)
}

# 1. Load Prepared Data --------------------------------------------------------
cat("Loading combined taxonomy data...\n")
combined_tax <- read.csv("processed_data/combined_taxonomy.csv")

cat("Loading feature table data...\n")
feature_table <- read.csv("processed_data/feature_table.csv", row.names = 1)

# Data validation
cat("Data validation:\n")
cat("- Total features in combined taxonomy:", nrow(combined_tax), "\n")
cat("- QIIME2 features:", sum(combined_tax$Pipeline == "QIIME2"), "\n")
cat("- DADA2 features:", sum(combined_tax$Pipeline == "DADA2"), "\n")
cat("- Feature table dimensions:", dim(feature_table), "\n")

cat("Data loading complete!\n")