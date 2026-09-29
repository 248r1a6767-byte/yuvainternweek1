# ==============================================================================
# Script: 01_initial_inspection.R
# Purpose: Import raw Superstore data, verify raw dimensions, inspect schema,
#          execute str(), summary(), head(), tail(), and capture real outputs.
# Project: Superstore Data Cleaning, Preprocessing and Preliminary Analysis Using R
# Author: Senior R Data Analyst & QA Specialist
# Date: 2026-09-29
# ==============================================================================

if (!exists("theme_superstore_eda")) {
  source("R/00_setup.R")
}

raw_path <- file.path("data", "raw", "superstore_raw.csv")

if (!file.exists(raw_path)) {
  stop("FATAL ERROR: Raw dataset not found at: ", raw_path)
}

message("Ingesting raw Superstore dataset from: ", raw_path)

# Ingest raw CSV with readr, preserving initial column structure
superstore_raw <- read_csv(
  file = raw_path,
  locale = locale(encoding = "latin1"),
  show_col_types = FALSE
)

# 1. Structural Verification ---------------------------------------------------
raw_nrow <- nrow(superstore_raw)
raw_ncol <- ncol(superstore_raw)
raw_dim  <- dim(superstore_raw)
raw_names <- colnames(superstore_raw)

# 2. Capture str() and summary() Outputs ----------------------------------------
str_txt <- capture.output(str(superstore_raw))
writeLines(str_txt, file.path("outputs", "console_outputs", "str_raw_output.txt"))

summary_txt <- capture.output(summary(superstore_raw))
writeLines(summary_txt, file.path("outputs", "console_outputs", "summary_raw_output.txt"))

# Comprehensive initial inspection log
inspection_log <- c(
  "==============================================================================",
  "               INITIAL DATA INSPECTION: SUPERSTORE RAW DATASET                ",
  "==============================================================================",
  sprintf("Inspection Timestamp   : %s", Sys.time()),
  sprintf("Observed Total Rows    : %s", format(raw_nrow, big.mark = ",")),
  sprintf("Observed Total Columns : %d", raw_ncol),
  "------------------------------------------------------------------------------",
  "COLUMN NAMES AND OBSERVED INITIAL TYPES:",
  paste(sprintf("  [%02d] %-16s | Type: %s | Missing: %d",
                seq_along(raw_names),
                raw_names,
                sapply(superstore_raw, function(x) class(x)[1]),
                sapply(superstore_raw, function(x) sum(is.na(x)))),
        collapse = "\n"),
  "=============================================================================="
)
writeLines(inspection_log, file.path("outputs", "console_outputs", "initial_inspection.txt"))

# 3. Export Raw Schema Summary Table -------------------------------------------
raw_schema <- data.frame(
  Column_Index = seq_along(raw_names),
  Variable_Name = raw_names,
  Initial_Data_Type = sapply(superstore_raw, function(x) class(x)[1]),
  Sample_Value_1 = sapply(superstore_raw, function(x) as.character(x[1])),
  Sample_Value_2 = sapply(superstore_raw, function(x) as.character(x[2])),
  Missing_Count = sapply(superstore_raw, function(x) sum(is.na(x))),
  Unique_Values = sapply(superstore_raw, function(x) length(unique(x))),
  stringsAsFactors = FALSE
)

write_csv(raw_schema, file.path("outputs", "tables", "raw_schema_summary.csv"))

cat("\n")
cat(paste(inspection_log, collapse = "\n"))
cat("\n\n")

message("01_initial_inspection.R completed successfully.")
