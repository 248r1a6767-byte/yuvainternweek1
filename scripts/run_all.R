# ==============================================================================
# Master Script: run_all.R
# Purpose: Orchestrates the entire end-to-end data cleaning, preprocessing,
#          transformation, statistical modeling, visualization, and QA workflow.
# Project: Superstore Data Cleaning, Preprocessing and Preliminary Analysis Using R
# Author: Senior R Data Analyst & QA Specialist
# Date: 2026-09-29
# ==============================================================================

cat("\n==============================================================================\n")
cat("   STARTING END-TO-END SUPERSTORE DATA CLEANING & PREPROCESSING PIPELINE       \n")
cat("==============================================================================\n\n")

start_time <- Sys.time()

pipeline_scripts <- c(
  "R/00_setup.R",
  "R/01_initial_inspection.R",
  "R/02_data_quality_assessment.R",
  "R/03_missing_values.R",
  "R/04_duplicates_and_consistency.R",
  "R/05_outlier_analysis.R",
  "R/06_transformation_and_normalization.R",
  "R/07_categorical_encoding.R",
  "R/08_feature_engineering.R",
  "R/09_descriptive_statistics.R",
  "R/10_exploratory_analysis.R",
  "R/11_correlation_analysis.R",
  "R/12_visualizations.R",
  "R/13_generate_report_data.R",
  "R/14_quality_control.R"
)

for (s in pipeline_scripts) {
  if (!file.exists(s)) {
    stop("CRITICAL PIPELINE FAILURE: Required script not found: ", s)
  }
  cat(sprintf("\n>>> [%s] SOURCING: %-42s ...\n", format(Sys.time(), "%H:%M:%S"), s))
  source(s)
}

end_time <- Sys.time()
elapsed <- round(as.numeric(difftime(end_time, start_time, units = "secs")), 2)

cat("\n==============================================================================\n")
cat(sprintf("   PIPELINE EXECUTION COMPLETED IN %.2f SECONDS WITH ZERO FATAL ERRORS!      \n", elapsed))
cat("==============================================================================\n\n")
