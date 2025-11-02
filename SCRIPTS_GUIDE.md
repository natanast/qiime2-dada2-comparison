# Command Line Execution Log - Ubuntu Terminal

## QIIME2 Moving Pictures Tutorial Analysis

### Data Processing Workflow:
### Followed the official QIIME2 Moving Pictures tutorial to generate reference taxonomy results using the standard QIIME2 pipeline.

### Data Processing Workflow:

#### 1.Followed Qiime2 Moving Pictures Tutorial:
#### -Data Import & Demultiplexing
#### -Denoising with DADA2
#### -Taxonomy Classification
#### -Analysis Outputs

### Final Saved Output:
### qiime2_taxonomy.qza - Taxonomic classifications from QIIME2 pipeline


## DADA2 Standalone Analysis & Conversion

### Data Processing Workflow:

#### 1.Followed DADA2 Tutorial using Moving Pictures dataset:
#### -Used single-end reads only (no reverse reads)
#### -Quality filtering with truncLen = 120
#### -Identified 771 ASVs from 34 samples
#### -Removed chimeras (96.52% sequences preserved)
#### -Assigned taxonomy using Silva v138.1 database

#### 2.Saved DADA2 Results as TSV file:

``r
write.table(taxa, "data/dada2_data/dada2_taxonomy.tsv", 
            sep = "\t", quote = FALSE, col.names = NA)

#### 3.Converted to QIIME2 Format:

``bash
qiime tools import \
  --input-path dada2_data/dada2_taxonomy.tsv \
  --type 'FeatureData[Taxonomy]' \
  --input-format HeaderlessTSVTaxonomyFormat \
  --output-path dada2_data/dada2_taxonomy.qza

#### 4. Final Output:
#### -dada2_taxonomy.qza - DADA2 taxonomy in QIIME2 format
#### -Ready for comparison with QIIME2 Moving Pictures results

### Run in Ubuntu the following:
Rscript scripts/01_f1score_analysis.R


## Script 1: export_data.sh

### Commands Executed:

```bash
# Navigated to scripts directory
cd /mnt/c/Users/Aspasia/Desktop/Thesis\ ΕΚΕΤΑ/qiime2-dada2-comparison/scripts/

# Made the script executable
chmod +x export_data.sh

# Ran the export script
./export_data.sh