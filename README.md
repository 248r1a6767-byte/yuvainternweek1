# Superstore Data Cleaning and Preliminary Analysis Using R

**Internship Program:** Data Analytics & Science (Week 1 Task)  
**Primary Technology:** R (v4.6.1), `ggplot2`, `dplyr`, `tidyr`, `readr`, `lubridate`, `scales`, `forcats`, `patchwork`  
**Dataset Analyzed:** Kaggle / Tableau Sample Superstore Dataset (9,994 records, 21 variables)  
**Main Report Deliverable:** `report/Superstore_Data_Cleaning_Preliminary_Analysis.docx` (Complete Word Report)  
**Pipeline Orchestrator:** `scripts/run_all.R` (100% reproducible execution in ~14 seconds)

---

## 1. Project Overview
This project delivers a comprehensive, reproducible, and academically rigorous data cleaning, preprocessing, feature transformation, and preliminary exploratory analysis of the Superstore retail sales dataset. Rather than superficial summary statistics, the project conducts an exhaustive audit across structural completeness, duplicate validation, postal code formatting, non-parametric outlier fencing, Min-Max normalization, Z-score standardization, one-hot dummy categorical encoding, and bivariate correlation modeling.

---

## 2. Project Objectives
* **Data Cleaning & Auditing:** Audit completeness, deduplicate transactions, standardize whitespace, fix truncated spatial codes, and parse international dates.
* **Missing-Value Analysis:** Quantify empirical completeness and benchmark theoretical missing-data mechanisms (MCAR, MAR, MNAR) and imputation strategies without fabricating artificial data.
* **Outlier Detection & Evaluation:** Implement Tukey's $1.5 \times \text{IQR}$ fencing bounds on numerical measures, inspect extreme records, and justify retention based on commercial validity.
* **Feature Rescaling:** Implement and contrast Min-Max Normalization $[0, 1]$ and Z-Score Standardization $\mathcal{N}(0, 1)$.
* **Categorical Encoding:** Transform factors and engineer one-hot dummy variable feature matrices (`model.matrix`) while avoiding multicollinearity (dummy variable trap).
* **Feature Engineering:** Derive 12 operational, financial, and temporal metrics (`Shipping_Days`, `Profit_Margin`, chronological calendar attributes, and discount bands).
* **Exploratory Data Analysis (EDA):** Quantify business dynamics across categories, regions, customer segments, and discount bands.
* **Correlation Analysis:** Estimate parametric Pearson and non-parametric Spearman rank correlation matrices with formal hypothesis testing (`cor.test`).
* **Visual Analytics:** Generate 16 publication-grade figures at 300 DPI adhering to ggplot2 Grammar of Graphics.
* **Executive Report:** Synthesize findings into a publication-grade, professionally formatted Microsoft Word document.

---

## 3. Dataset Overview
* **Dataset Title:** Kaggle Superstore Sales Dataset / Tableau Sample Superstore
* **Observational Unit:** Individual product line item within a commercial customer order.
* **Dimensions:** 9,994 transaction rows × 21 raw columns (expanded to 33 cleaned columns and 47 analysis-ready columns).
* **Temporal Horizon:** January 4, 2011 to December 31, 2014 (48 continuous calendar months).
* **Geographic Scope:** United States nationwide coverage (49 states and 531 unique cities).

---

## 4. Dataset Source & Provenance
* **Repository:** Kaggle (Vivek Patel mirror repository)
* **URL:** https://www.kaggle.com/datasets/vivek468/superstore-dataset-final
* **File Name:** `superstore_raw.csv` (ingested from `Superstore.csv`)
* **Format:** Comma-Separated Values (CSV, UTF-8 / Latin1 compatible)
* **Access Date:** September 2026
* **Redistribution:** Public educational / commercial analytical domain

---

## 5. Data Description & Schema
The dataset encompasses four operational business dimensions:
1. **Identifiers & Grouping Keys:** `Row ID`, `Order ID`, `Customer ID`, `Product ID`.
2. **Customer & Geographic Attributes:** `Customer Name`, `Segment` (Consumer, Corporate, Home Office), `Country`, `City`, `State`, `Postal Code`, `Region` (Central, East, South, West).
3. **Product & Merchandising Hierarchy:** `Category` (Furniture, Office Supplies, Technology), `Sub-Category` (17 departments: Chairs, Copiers, Tables, etc.), `Product Name`.
4. **Financial & Operational Measures:** `Sales` ($0.44 to $22,638.48), `Quantity` (1 to 14 units), `Discount` (0% to 80%), `Profit` (-$6,599.98 to +$8,399.98), `Order Date`, `Ship Date`, `Ship Mode`.

---

## 6. Methodology
The analytical workflow is structured into 15 modular R scripts executed sequentially via `scripts/run_all.R`:
```text
Ingestion -> Quality Audit -> Missingness Scan -> Deduplication -> Outlier Fencing 
  -> Rescaling (Min-Max/Z-Score) -> Categorical Encoding -> Feature Engineering 
  -> Descriptive Statistics -> EDA & Impact -> Correlation Modeling -> 16 Visualizations -> QA
```

---

## 7. Data Cleaning Actions Taken
* **Whitespace Standardization:** Applied `trimws()` across all descriptive character columns to eliminate invisible leading and trailing whitespace.
* **Postal Code Zero-Padding:** Replaced truncated integer representations with padded 5-digit strings via `sprintf("%05s", as.character(Postal_Code))`, repairing northeastern zip codes (e.g. Burlington, VT `5408` -> `05408`).
* **Date Parsing:** Converted international `DD-MM-YYYY` character strings into native Date objects via `lubridate::dmy()`. Validated that `Ship Date >= Order Date` for 100% of records with zero chronological inversions.
* **Domain Sanity Validation:** Confirmed that `Sales > 0`, `Quantity > 0`, `Discount` is within $[0.0, 0.8]$, and negative profits reflect commercial losses rather than accounting corruption.

---

## 8. Missing-Value Handling
* **Empirical Completeness:** Vectorized scans confirmed exactly 0 missing cells across all 209,874 matrix elements (100% empirical completeness).
* **Ethical Adherence:** In strict accordance with assignment instructions, zero synthetic `NA` values were fabricated.
* **Methodological Evaluation:** The project documents theoretical missingness mechanisms (MCAR, MAR, MNAR) and provides a formal benchmarking matrix of imputation techniques (mean, median, mode, MICE, KNN) for future analytical applications.

---

## 9. Outlier Analysis & Fencing
Tukey's $1.5 \times \text{IQR}$ fencing boundaries were calculated for all continuous measures:
* **Sales:** Lower = -$271.71, Upper = $498.93 (1,167 outliers, 11.68%).
* **Profit:** Lower = -$39.72, Upper = $70.82 (1,881 outliers, 18.82%).
* **Discount:** Lower = -0.30, Upper = 0.50 (856 outliers, 8.57%).
* **Quantity:** Lower = -2.50, Upper = 9.50 (170 outliers, 1.70%).
* **Treatment Decision:** Retained 100% of extreme observations. Qualitative forensic auditing proved that all outliers reflect genuine commercial transactions (e.g., enterprise hardware procurements or clearance liquidations) rather than measurement errors.

---

## 10. Normalization & Standardization
Rescaling was implemented across continuous numerical variables:
* **Min-Max Normalization:** Rescaled `Sales`, `Profit`, `Quantity`, `Discount`, and `Shipping_Days` to the closed interval $[0, 1]$: $x_{\text{norm}} = (x - \min(x)) / (\max(x) - \min(x))$.
* **Z-Score Standardization:** Standardized variables to zero mean and unit variance: $z = (x - \bar{x}) / s$.
* **Logarithmic Transformation:** Computed $\log_{10}(\text{Sales})$ and signed $\text{sign}(\text{Profit}) \times \log_{10}(|\text{Profit}| + 1)$ to normalize highly skewed distributions.
* **Non-Scalable Exclusions:** Identifiers (`Row ID`, `Order ID`) and spatial routing codes (`Postal Code`) were excluded.

---

## 11. Categorical Encoding
* **Factor Conversion:** Categorical predictors were factored with explicit business reference baselines to prevent dummy variable traps in linear modeling: `Segment` (Ref: Consumer), `Category` (Ref: Furniture), `Region` (Ref: Central), `Ship Mode` (Ref: Standard Class).
* **One-Hot Dummy Matrix:** Expanded predictors via `model.matrix(~ Segment + Category + Region + Ship_Mode - 1)` to generate 14 binary (0/1) indicators for machine learning pipelines.

---

## 12. Exploratory Data Analysis (EDA)
* **Revenue Balance:** Gross sales revenue is evenly distributed across Technology ($836.2K, 36.4%), Furniture ($742.0K, 32.3%), and Office Supplies ($719.0K, 31.3%).
* **Profit Asymmetry:** Technology captures 50.8% of profit ($145.5K) at a 17.4% margin; Furniture collapses to just 6.4% of profit ($18.5K) at an anemic 2.49% margin.
* **Discount Band Impact:** Transactions discounted at 0% achieve a 30.0% margin; transactions discounted between 31% and 50% suffer an average margin of -37.8%, while discounts >50% collapse to -97.3% margin.
* **Seasonal Momentum:** Sales expanded by 51.6% between 2011 ($484.2K) and 2014 ($733.9K), driven by recurring Q4 surges peaking in November and December.

---

## 13. Visualization Library (16 Figures, 300 DPI)
All figures are exported to `outputs/figures/` at 300 DPI (10 × 6 inches):
1. `fig01_missing_values.png` – Diagnostic completeness bar chart (100% complete across 21 variables).
2. `fig02_sales_distribution.png` – Log10 histogram displaying severe positive skewness (Median $54.49 vs Mean $229.86).
3. `fig03_profit_distribution.png` – Diverging histogram centered on $0 breakeven (18.7% loss-making orders).
4. `fig04_sales_by_category.png` – Horizontal bar chart of gross revenue by merchandise category.
5. `fig05_profit_by_category.png` – Comparative bar chart of net profit and commercial profit margin.
6. `fig06_sales_by_region.png` – Geographic sales revenue distribution across US operational quadrants.
7. `fig07_profit_by_region.png` – Geographic net profit and commercial margins across US regions.
8. `fig08_sales_by_segment.png` – Customer market segment volume and average order values.
9. `fig09_sales_over_time.png` – 48-month chronological sales trend with LOESS smoothing curve.
10. `fig10_profit_over_time.png` – 48-month chronological net profit trend with LOESS trajectory.
11. `fig11_sales_vs_profit_scatter.png` – Bivariate scatter plot showing heteroscedastic risk dispersion.
12. `fig12_discount_vs_profit.png` – Scatter plot highlighting the non-linear 20% discount cliff.
13. `fig13_quantity_vs_sales.png` – Logarithmic box plot and scatter across purchase unit counts (1 to 14).
14. `fig14_subcategory_sales_profit.png` – Diverging horizontal bar chart across all 17 product sub-categories.
15. `fig15_outlier_boxplots.png` – Multi-panel composite box plot displaying numerical dispersion.
16. `fig16_correlation_heatmap.png` – Annotated Pearson linear correlation matrix heatmap.

---

## 14. Key Empirical Findings
1. **The Volume vs Profit Fallacy:** Top-line sales do not guarantee profitability. Technology produces over $145K in profit, while Furniture produces only $18.5K despite generating nearly equal gross revenue ($742K).
2. **The "Furniture Deficit" Identified:** Sub-category analysis isolates severe structural deficits in Tables (-$17,725.48 net loss) and Bookcases (-$3,472.56 net loss), which wipe out earnings from profitable lines like Chairs (+$26.6K).
3. **The 20% Discount Cliff:** Discounts up to 20% maintain positive profitability, but discounts exceeding 20% trigger severe commercial deficits (Spearman rank correlation $\rho = -0.5434$).
4. **Regional Discounting Disparity:** The Central region discounts aggressively (24.0% average), eroding net margin to 7.92% ($39.7K profit on $501.2K sales). In contrast, the West region discounts conservatively (10.9% average), capturing $108.4K in profit at a 14.94% margin.
5. **Logistics SLA Excellence:** Order fulfillment operations exhibit 100% adherence to logistics service-level agreements: Same Day ships in 0.04 days on average (max 1 day); Standard Class ships in 5.01 days on average (max 7 days).

---

## 15. Repository Structure
```text
Superstore-R-Data-Cleaning-Project/
├── README.md                                 # Master repository documentation
├── LICENSE                                   # MIT Open Source License
├── .gitignore                                # Git ignore configuration
├── submission_description.txt                # 350-word executive summary for submission portal
├── project_metadata.md                       # Comprehensive metadata and provenance
│
├── data/
│   ├── raw/
│   │   └── superstore_raw.csv                # Immutable raw dataset (9,994 rows x 21 columns)
│   └── processed/
│       ├── superstore_cleaned.csv            # Cleaned, interpretable dataset (33 columns)
│       ├── superstore_analysis_ready.csv     # Scaled & one-hot encoded dataset (47 columns)
│       ├── superstore_cleaned.rds            # Serialized native R clean dataset
│       └── data_dictionary.csv               # 21-variable architectural data dictionary
│
├── R/
│   ├── 00_setup.R                            # Environment setup, package manager, ggplot2 theme
│   ├── 01_initial_inspection.R               # Ingestion, dim, names, str, summary, glimpse
│   ├── 02_data_quality_assessment.R          # Quality profiling and data dictionary compilation
│   ├── 03_missing_values.R                   # Completeness audit and theoretical mechanisms
│   ├── 04_duplicates_and_consistency.R       # Deduplication, string trimming, postal code padding
│   ├── 05_outlier_analysis.R                 # Tukey's 1.5xIQR fencing and record forensics
│   ├── 06_transformation_and_normalization.R # Min-Max rescaling and Z-score standardization
│   ├── 07_categorical_encoding.R             # Factor levels and one-hot dummy matrix generation
│   ├── 08_feature_engineering.R              # Feature derivation and dataset serialization
│   ├── 09_descriptive_statistics.R           # Parametric and non-parametric summary statistics
│   ├── 10_exploratory_analysis.R             # Business exploratory analysis and before-after auditing
│   ├── 11_correlation_analysis.R             # Pearson and Spearman correlation matrices and tests
│   ├── 12_visualizations.R                   # Generation of all 16 figures at 300 DPI
│   ├── 13_generate_report_data.R             # Report data manifest compilation
│   └── 14_quality_control.R                  # Automated QA asset inventory validation
│
├── scripts/
│   └── run_all.R                             # Master pipeline execution orchestrator
│
├── outputs/
│   ├── tables/                               # 22 tabular summary CSV exports
│   ├── figures/                              # 16 high-resolution chart images (300 DPI)
│   ├── diagnostics/                          # QA logs, missingness profiles, metric manifests
│   ├── statistics/                           # Statistical model summaries
│   └── console_outputs/                      # Real console text captures (str, summary, inspection)
│
├── screenshots/                              # Visual process aids and workflow diagrams
│
├── report/
│   └── Superstore_Data_Cleaning_Preliminary_Analysis.docx # Official 26-section Word report
│
├── generate_doc_report.py                    # Programmatic Word DOCX report synthesizer
│
└── docs/
    ├── methodology.md                        # In-depth technical methodology
    ├── reproducibility.md                    # Environment manifest and reproduction protocol
    └── requirement_traceability.csv          # Requirement-to-asset compliance matrix
```

---

## 16. Technologies & Environment
* **Language:** R (version 4.6.1 ucrt, 64-bit Windows)
* **Libraries:** `readr` (2.2.0), `dplyr` (1.2.1), `tidyr` (1.3.2), `lubridate` (1.9.5), `ggplot2` (4.0.3), `scales` (1.4.0), `forcats` (1.0.1), `patchwork` (1.3.2)
* **Document Engine:** Python (3.13) with `python-docx` (1.2.0) for native XML Word synthesis

---

## 17. Reproducibility Protocol
To reproduce the entire project from source:
```powershell
# Open terminal in Superstore-R-Data-Cleaning-Project:
Rscript scripts/run_all.R
python generate_doc_report.py
```
Total pipeline execution completes in ~14 seconds with zero fatal errors.

---

## 18. Limitations
* **Observational Architecture:** The dataset represents historical retail records without randomized A/B pricing interventions; correlation does not prove causality.
* **Omitted Cost Granularity:** The dataset lacks explicit Cost of Goods Sold (COGS), inbound freight, and labor allocations.
* **Temporal Scope:** Covers 2011 to 2014; post-2015 macroeconomic and e-commerce channel shifts are unobserved.

---

## 19. License & Attribution
* **Software License:** MIT Open Source License.
* **Dataset Attribution:** Sample Superstore data originated from Tableau Software and is redistributed under public educational licenses via Kaggle.
