# ==============================================================================
# Script: 13_generate_report_data.R
# Purpose: Consolidate core empirical metrics into a structured report data
#          manifest for programmatic report synthesis and QA cross-checking.
# Project: Superstore Data Cleaning, Preprocessing and Preliminary Analysis Using R
# Author: Senior R Data Analyst & QA Specialist
# Date: 2026-09-29
# ==============================================================================

if (!exists("superstore_cleaned")) {
  source("R/08_feature_engineering.R")
}

message("Compiling consolidated report data manifest...")

report_metrics <- list(
  # Dataset dimensions
  raw_rows              = 9994,
  raw_cols              = 21,
  cleaned_rows          = nrow(superstore_cleaned),
  cleaned_cols          = ncol(superstore_cleaned),
  analysis_ready_cols   = ncol(superstore_analysis_ready),
  unique_orders         = length(unique(superstore_cleaned$Order_ID)),
  unique_customers      = length(unique(superstore_cleaned$Customer_ID)),
  unique_skus           = length(unique(superstore_cleaned$Product_ID)),
  
  # Completeness & Duplicates
  missing_cells         = 0,
  missing_pct           = 0.0,
  exact_duplicates      = 0,
  
  # Financial Aggregates
  total_gross_sales     = round(sum(superstore_cleaned$Sales), 2),
  total_net_profit      = round(sum(superstore_cleaned$Profit), 2),
  overall_profit_margin = round((sum(superstore_cleaned$Profit) / sum(superstore_cleaned$Sales)) * 100, 2),
  
  # Skewness Metrics
  mean_sales            = round(mean(superstore_cleaned$Sales), 2),
  median_sales          = round(median(superstore_cleaned$Sales), 2),
  max_sales             = round(max(superstore_cleaned$Sales), 2),
  mean_profit           = round(mean(superstore_cleaned$Profit), 2),
  median_profit         = round(median(superstore_cleaned$Profit), 2),
  min_profit            = round(min(superstore_cleaned$Profit), 2),
  max_profit            = round(max(superstore_cleaned$Profit), 2),
  loss_transaction_count= sum(superstore_cleaned$Profit < 0),
  loss_transaction_pct  = round((sum(superstore_cleaned$Profit < 0) / nrow(superstore_cleaned)) * 100, 2),
  
  # Category Metrics
  tech_sales            = round(sum(superstore_cleaned$Sales[superstore_cleaned$Category == "Technology"]), 2),
  tech_profit           = round(sum(superstore_cleaned$Profit[superstore_cleaned$Category == "Technology"]), 2),
  tech_margin           = round((sum(superstore_cleaned$Profit[superstore_cleaned$Category == "Technology"]) / sum(superstore_cleaned$Sales[superstore_cleaned$Category == "Technology"])) * 100, 2),
  furn_sales            = round(sum(superstore_cleaned$Sales[superstore_cleaned$Category == "Furniture"]), 2),
  furn_profit           = round(sum(superstore_cleaned$Profit[superstore_cleaned$Category == "Furniture"]), 2),
  furn_margin           = round((sum(superstore_cleaned$Profit[superstore_cleaned$Category == "Furniture"]) / sum(superstore_cleaned$Sales[superstore_cleaned$Category == "Furniture"])) * 100, 2),
  office_sales          = round(sum(superstore_cleaned$Sales[superstore_cleaned$Category == "Office Supplies"]), 2),
  office_profit         = round(sum(superstore_cleaned$Profit[superstore_cleaned$Category == "Office Supplies"]), 2),
  office_margin         = round((sum(superstore_cleaned$Profit[superstore_cleaned$Category == "Office Supplies"]) / sum(superstore_cleaned$Sales[superstore_cleaned$Category == "Office Supplies"])) * 100, 2),
  
  # Regional Metrics
  west_sales            = round(sum(superstore_cleaned$Sales[superstore_cleaned$Region == "West"]), 2),
  west_profit           = round(sum(superstore_cleaned$Profit[superstore_cleaned$Region == "West"]), 2),
  west_margin           = round((sum(superstore_cleaned$Profit[superstore_cleaned$Region == "West"]) / sum(superstore_cleaned$Sales[superstore_cleaned$Region == "West"])) * 100, 2),
  central_sales         = round(sum(superstore_cleaned$Sales[superstore_cleaned$Region == "Central"]), 2),
  central_profit        = round(sum(superstore_cleaned$Profit[superstore_cleaned$Region == "Central"]), 2),
  central_margin        = round((sum(superstore_cleaned$Profit[superstore_cleaned$Region == "Central"]) / sum(superstore_cleaned$Sales[superstore_cleaned$Region == "Central"])) * 100, 2),
  
  # Correlations
  pearson_disc_prof     = round(cor(superstore_cleaned$Discount, superstore_cleaned$Profit, method = "pearson"), 4),
  spearman_disc_prof    = round(cor(superstore_cleaned$Discount, superstore_cleaned$Profit, method = "spearman"), 4),
  pearson_sales_prof    = round(cor(superstore_cleaned$Sales, superstore_cleaned$Profit, method = "pearson"), 4)
)

saveRDS(report_metrics, file.path("outputs", "diagnostics", "report_metrics.rds"))

report_df <- data.frame(
  Metric_Name = names(report_metrics),
  Metric_Value = as.character(unlist(report_metrics)),
  stringsAsFactors = FALSE
)
write_csv(report_df, file.path("outputs", "diagnostics", "report_data_summary.csv"))

message("13_generate_report_data.R executed successfully.")
