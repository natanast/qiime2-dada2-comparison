# QIIME2 vs. DADA2: A Comparative Analysis for 16S rRNA Amplicon Data

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![QIIME2](https://img.shields.io/badge/QIIME2-2023.9-brightgreen)](https://qiime2.org)
[![DADA2](https://img.shields.io/badge/DADA2-1.26.0-orange)](https://benjjneb.github.io/dada2/)
![Python](https://img.shields.io/badge/Python-3.8%2B-blue)
![R](https://img.shields.io/badge/R-4.0%2B-blue)

A comprehensive, reproducible workflow for comparing **QIIME2** and **DADA2** pipelines for 16S rRNA gene amplicon sequencing analysis. This project evaluates performance metrics, output differences, and biological interpretations between these widely-used bioinformatics tools.

## Table of Contents

- [About](#about)
- [Features](#features)
- [Quick Start](#quick-start)
- [Installation](#installation)
- [Usage](#usage)
- [Contributing and Support](#contributing)
- [Acknowledgments](#acknowledgments)
- [Citation](#citation)
- [License](#license)

## About

Microbiome analysis of 16S rRNA sequencing data requires robust bioinformatics pipelines for quality control, denoising, and generating Amplicon Sequence Variants (ASVs). This project provides a systematic comparison between:

- **QIIME2**: A comprehensive, all-in-one platform for microbiome analysis
- **DADA2**: A specialized R package for high-resolution sample inference

### Research Questions

- How do ASV tables from QIIME2 (via q2-dada2) and standalone DADA2 differ in terms of feature count and read depth?
- What are the computational time and resource usage differences between these pipelines?
- How does the choice of tool influence downstream ecological conclusions (alpha and beta diversity)?
- What are the practical implications for researchers choosing between these approaches?

## Features

- **🔍 Comprehensive Comparison**: Side-by-side evaluation of QIIME2 and DADA2 pipelines
- **🔄 Reproducible Workflow**: Complete scripts for both analysis pipelines
- **📊 Performance Metrics**: Computational efficiency and resource usage analysis
- **🧬 Biological Validation**: Comparison of taxonomic assignments and diversity metrics
- **📈 Visualization**: Automated generation of comparative plots and reports

## Quick Start

``bash
### Clone the repository
git clone https://github.com/AspaLav/qiime2-dada2-comparison.git
cd qiime2-dada2-comparison

### Run the complete analysis
./scripts/run_qiime2_dada2.sh
Rscript scripts/run_dada2_standalone.R

### Generate comparison report
jupyter notebook notebooks/Comparative_Analysis.ipynb

## Installation

### Requirements
- **QIIME2 2023.9+**- [text](https://docs.qiime2.org/2023.9/install/)
- **R 4.0+** with DADA2, ggplot2, phyloseq
- **Python 3.8+** with pandas, matplotlib, scikit-bio, jupyter

### Step-by-Step Setup

``bash
#### Clone the repository
git clone https://github.com/AspaLav/qiime2-dada2-comparison.git
cd qiime2-dada2-comparison

#### Set up the Python Environment 
pip install -r requirements.txt

``R
#### Install R packages
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")
BiocManager::install("dada2")
install.packages(c("ggplot2", "phyloseq", "vegan"))

``bash
#### Download example data
##### Using the QIIME2 moving pictures dataset
wget -O "data/emp-single-end-sequences.qza" \
  "https://data.qiime2.org/2023.9/tutorials/moving-pictures/emp-single-end-sequences.qza"

## Usage

### Running the Complete Analysis

#### QIIME2 Pipeline:
``bash
chmod +x scripts/run_qiime2_dada2.sh
./scripts/run_qiime2_dada2.sh

#### DADA2 Pipeline:
``R
source("scripts/run_dada2_standalone.R")

## Contributing and Support

If you would like to contribute to this pipeline, please see the [contributing guidelines](CONTRIBUTING.md).

For questions, discussions, and support:
- 💬 Use [GitHub Discussions](https://github.com/AspaLav/qiime2-dada2-comparison/discussions)
- 🐛 Report bugs via [GitHub Issues](https://github.com/AspaLav/qiime2-dada2-comparison/issues)

## Acknowledgments

This project builds upon the excellent work of:

- **QIIME2 Development Team** - For the comprehensive microbiome analysis platform
- **DADA2 Developers** - For the robust denoising algorithm  
- **QIIME2 "Moving Pictures" Tutorial** - For foundational datasets and workflows

## Citation

@software{qiime2_dada2_comparison,
  title = {QIIME2 vs. DADA2: Comparative Analysis for 16S rRNA Amplicon Data},
  author = {AspaLav},
  year = {2025},
  url = {https://github.com/AspaLav/qiime2-dada2-comparison},
  note = {A reproducible workflow for comparing microbiome analysis pipelines}
}

## License

MIT License

Copyright (c) Aspasia Lavazou

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.



