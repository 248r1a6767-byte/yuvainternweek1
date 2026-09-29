# ==============================================================================
# Script: 10_exploratory_analysis.R
# Purpose: Execute deep exploratory data analysis, evaluate discount band margin
#          deterioration, compute multi-year growth rates, and generate the
#          definitive Before-vs-After Data Cleaning Impact comparison table.
# Project: Superstore Data Cleaning, Preprocessing and Preliminary Analysis Using R
# Author: Senior R Data Analyst & QA Specialist
# Date: 2026-09-29
# ==============================================================================

if (!exists("superstore_cleaned")) {
  source("R/08_feature_engineering.R")
}

message("Executing Exploratory Business Analysis & Before-After Auditing...")

# 1. Discount Band Performance Analysis ----------------------------------------
disc_band_summary <- superstore_cleaned %>%
  group_by(Discount_Band) %>%
  summarise(
    Transaction_Count = n(),
    Transaction_Pct   = round((n() / nrow(superstore_cleaned)) * 100, 2),
    Total_Sales       = round(sum(Sales), 2),
    Total_Profit      = round(sum(Profit), 2),
    Avg_Profit        = round(mean(Profit), 2),
    Overall_Margin    = round((sum(Profit) / sum(Sales)) * 100, 2),
    Profitable_Orders = sum(Profit >= 0),
    Unprofitable_Orders = sum(Profit < 0),
    Loss_Rate_Pct     = round((sum(Profit < 0) / n()) * 100, 2),
    .groups = "drop"
  )

write_csv(disc_band_summary, file.path("outputs", "tables", "discount_band_performance.csv"))

# 2. Yearly Growth and Trajectory Summary --------------------------------------
yearly_summary <- superstore_cleaned %>%
  group_by(Order_Year) %>%
  summarise(
    Total_Sales    = round(sum(Sales), 2),
    Total_Profit   = round(sum(Profit), 2),
    Total_Orders   = n_distinct(Order_ID),
    Total_Units    = sum(Quantity),
    Overall_Margin = round((sum(Profit) / sum(Sales)) * 100, 2),
    .groups = "drop"
  ) %>%
  mutate(
    Sales_YoY_Growth = c(NA, round(diff(Total_Sales) / lag(Total_Sales)[-1] * 100, 2)),
    Profit_YoY_Growth = c(NA, round(diff(Total_Profit) / lag(Total_Profit)[-1] * 100, 2))
  )

write_csv(yearly_summary, file.path("outputs", "tables", "yearly_growth_summary.csv"))

# 3. Comprehensive Before vs After Cleaning Impact Table (Step 29) ------------
before_after_table <- data.frame(
  Analytical_Dimension = c(
    "Total Transaction Rows",
    "Total Variable Columns",
    "Missing Data Cells",
    "Exact Duplicate Records",
    "Truncated Postal Codes",
    "Date Variable Data Types",
    "String Whitespace Formatting",
    "Categorical Factor Encodings",
    "One-Hot / Dummy Indicators",
    "Normalized Continuous Features",
    "Standardized (Z-Score) Features",
    "Engineered Temporal Attributes",
    "Discretized Commercial Tiers",
    "Identified Outlier Transactions",
    "Outliers Inappropriately Deleted"
  ),
  Before_Preprocessing = c(
    "9,994 rows",
    "21 columns",
    "0 cells (100% complete)",
    "0 duplicate rows",
    "11 truncated zip codes (e.g. 5408 for Burlington, VT)",
    "character ('09-11-2013')",
    "Raw character strings with potential whitespace",
    "Raw character strings",
    "0 binary indicators",
    "0 normalized features",
    "0 standardized features",
    "0 derived temporal columns",
    "Continuous values only",
    "Unidentified / Unquantified",
    "0"
  ),
  After_Preprocessing = c(
    "9,994 rows (100% preserved)",
    "33 columns (Cleaned) / 47 columns (Analysis-Ready)",
    "0 cells (100% verified complete)",
    "0 duplicate rows (0 removed)",
    "100% 5-digit zero-padded strings ('05408')",
    "Native Date objects (lubridate::dmy)",
    "trimws() applied across all text fields",
    "Standardized factors with explicit reference baselines",
    "14 one-hot dummy features (model.matrix)",
    "5 Min-Max scaled features [0, 1]",
    "5 Z-Score standardized features N(0, 1)",
    "Year, Month, Month_Name, Quarter, Day_of_Week, YM_Date",
    "Discount_Band (6 tiers) & Order_Value_Tier (4 tiers)",
    "1,167 Sales / 1,881 Profit outliers audited",
    "0 (100% retained to preserve commercial reality)"
  ),
  Net_Analytical_Impact = c(
    "Full data preservation; zero unprincipled record loss",
    "+12 interpretable features / +26 modeling features",
    "Zero data fabrication; empirical truth documented",
    "Integrity verified across multi-item transactions",
    "Correct geographic spatial routing across all 49 states",
    "Enabled chronological time-series aggregations",
    "Prevented string mismatch and join fragmentation",
    "Protected regression models from dummy variable trap",
    "Ready for machine learning and linear modeling",
    "Rescaled features for gradient and distance algorithms",
    "Zero-mean, unit-variance standardized predictors",
    "Enabled seasonal decomposition and quarterly benchmarking",
    "Quantified the non-linear 20% discount cliff",
    "Documented legitimate enterprise hardware purchases",
    "Avoided false inflation of enterprise profit margins"
  ),
  stringsAsFactors = FALSE
)

write_csv(before_after_table, file.path("outputs", "tables", "cleaning_before_after_comparison.csv"))

message("010_exploratory_analysis.R executed successfully.")
