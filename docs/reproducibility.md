# Reproducibility Protocol & Environment Manifest

## 1. System & Runtime Specifications
* **Operating System:** Windows 11 Home / Pro (x86_64-w64-mingw32)
* **R Environment:** R version 4.6.1 (2026-06-24 ucrt)
* **Execution Engine:** Native `Rscript.exe` CLI
* **Execution Working Directory:** `Superstore-R-Data-Cleaning-Project/`

---

## 2. Package Dependency Manifest
All packages were installed from the official Comprehensive R Archive Network (CRAN) mirror (`https://cloud.r-project.org`):

| Package Name | Minimum Version | Tested Version | Analytical Function |
|---|---|---|---|
| **readr** | 2.1.0 | 2.2.0 | Fast, robust CSV ingestion with encoding support |
| **dplyr** | 1.1.0 | 1.2.1 | Data manipulation, filtering, and grouped aggregation |
| **tidyr** | 1.3.0 | 1.3.2 | Tidy data reshaping, pivoting, and nesting |
| **lubridate** | 1.9.0 | 1.9.5 | Strict international date parsing (`dmy`) |
| **ggplot2** | 3.5.0 | 4.0.3 | Grammar of Graphics declarative visual analytics |
| **scales** | 1.3.0 | 1.4.0 | Currency (`$`), percentage (`%`), and log axis scaling |
| **forcats** | 1.0.0 | 1.0.1 | Factor level reordering and baseline definition |
| **patchwork** | 1.2.0 | 1.3.2 | Multi-panel composite chart construction |

---

## 3. End-to-End Pipeline Execution Instructions

### A. One-Line Full Execution
From a terminal or PowerShell prompt located in the project root directory (`Superstore-R-Data-Cleaning-Project/`):

```powershell
Rscript scripts/run_all.R
```

### B. Expected Execution Sequence and Timing
The master orchestrator executes 15 modular R scripts in strict sequential order:
1. `R/00_setup.R` – Environment configuration and library loading (~0.5s)
2. `R/01_initial_inspection.R` – Ingestion, `dim()`, `names()`, `str()`, `summary()` (~0.8s)
3. `R/02_data_quality_assessment.R` – Quality profiling and data dictionary compilation (~0.4s)
4. `R/03_missing_values.R` – Completeness scan and theoretical missingness benchmarking (~0.3s)
5. `R/04_duplicates_and_consistency.R` – Deduplication, string trimming, postal code padding (~0.5s)
6. `R/05_outlier_analysis.R` – Tukey's IQR boundary calculation and extreme transaction audit (~0.4s)
7. `R/06_transformation_and_normalization.R` – Min-Max and Z-score feature rescaling (~0.5s)
8. `R/07_categorical_encoding.R` – Factor levels and one-hot dummy matrix generation (~0.4s)
9. `R/08_feature_engineering.R` – Feature derivation and dataset serialization (`.csv`/`.rds`) (~0.6s)
10. `R/09_descriptive_statistics.R` – Parametric, non-parametric, and cross-tabulated metrics (~0.5s)
11. `R/10_exploratory_analysis.R` – Business exploratory analysis and before-after auditing (~0.4s)
12. `R/11_correlation_analysis.R` – Pearson and Spearman correlation matrices and tests (~0.4s)
13. `R/12_visualizations.R` – Generation of all 16 high-resolution charts at 300 DPI (~7.0s)
14. `R/13_generate_report_data.R` – Report data consolidation (~0.3s)
15. `R/14_quality_control.R` – Automated asset inventory verification (~0.3s)

* **Total Measured Execution Duration:** ~13.84 seconds.
* **Fatal Error Tolerance:** 0 fatal errors.

---

## 4. Output Verification Checkpoints
Upon successful pipeline execution, verify the generation of:
* `data/processed/superstore_cleaned.csv` (9,994 rows × 33 variables)
* `data/processed/superstore_analysis_ready.csv` (9,994 rows × 47 variables)
* `data/processed/data_dictionary.csv` (21 documented variables)
* `outputs/tables/` – 22 tabular CSV summary files
* `outputs/figures/` – 16 PNG visualization files (300 DPI, 10 × 6 inches)
* `outputs/console_outputs/` – 3 text captures of raw inspection logs (`str`, `summary`, inspection)
* `outputs/diagnostics/qa_validation_log.txt` – Confirms 100% QA audit pass
