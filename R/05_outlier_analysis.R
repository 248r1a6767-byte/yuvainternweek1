# ==============================================================================
# Script: 05_outlier_analysis.R
# Purpose: Non-parametric outlier detection using Tukey's 1.5 x IQR methodology,
#          fencing boundary calculation, qualitative transaction auditing, and
#          business-oriented treatment justification.
# Project: Superstore Data Cleaning, Preprocessing and Preliminary Analysis Using R
# Author: Senior R Data Analyst & QA Specialist
# Date: 2026-09-29
# ==============================================================================

if (!exists("superstore_clean_stage1")) {
  source("R/04_duplicates_and_consistency.R")
}

message("Executing systematic Outlier Analysis via Tukey's IQR Method...")

# 1. IQR Outlier Fencing Function ----------------------------------------------
compute_iqr_outliers <- function(df, var_name, treatment_decision, treatment_reason) {
  x <- df[[var_name]]
  q <- quantile(x, probs = c(0.25, 0.50, 0.75), na.rm = TRUE)
  q1 <- q[1]
  med <- q[2]
  q3 <- q[3]
  iqr_val <- q3 - q1
  lower_fence <- q1 - 1.5 * iqr_val
  upper_fence <- q3 + 1.5 * iqr_val
  
  outliers <- x < lower_fence | x > upper_fence
  n_outliers <- sum(outliers, na.rm = TRUE)
  pct_outliers <- (n_outliers / length(x)) * 100
  
  data.frame(
    Variable       = var_name,
    Q1_25          = round(q1, 2),
    Median         = round(med, 2),
    Q3_75          = round(q3, 2),
    IQR            = round(iqr_val, 2),
    Lower_Fence    = round(lower_fence, 2),
    Upper_Fence    = round(upper_fence, 2),
    Outlier_Count  = n_outliers,
    Outlier_Pct    = round(pct_outliers, 2),
    Min_Observed   = round(min(x, na.rm = TRUE), 2),
    Max_Observed   = round(max(x, na.rm = TRUE), 2),
    Treatment      = treatment_decision,
    Reason         = treatment_reason,
    stringsAsFactors = FALSE
  )
}

# 2. Build Outlier Summary Table -----------------------------------------------
outlier_table <- bind_rows(
  compute_iqr_outliers(
    superstore_clean_stage1, "Sales",
    "Retained", "Legitimate high-value enterprise commercial equipment orders"
  ),
  compute_iqr_outliers(
    superstore_clean_stage1, "Profit",
    "Retained", "Legitimate high gains and promotional liquidation losses"
  ),
  compute_iqr_outliers(
    superstore_clean_stage1, "Discount",
    "Retained", "Legitimate institutional clearance and promotional discount tiers"
  ),
  compute_iqr_outliers(
    superstore_clean_stage1, "Quantity",
    "Retained", "Legitimate bulk packaging and wholesale purchase quantities"
  ),
  compute_iqr_outliers(
    superstore_clean_stage1, "Shipping_Days",
    "Retained", "Legitimate operational logistics variation within SLA limits (0-7 d)"
  )
)

write_csv(outlier_table, file.path("outputs", "tables", "outlier_summary.csv"))

# 3. Forensic Transaction Inspection -------------------------------------------
# Inspect top 5 sales
top_sales <- superstore_clean_stage1 %>%
  arrange(desc(Sales)) %>%
  slice(1:5) %>%
  select(Row_ID, Order_ID, Order_Date_Clean, Customer_Name, Category, Sub_Category,
         Product_Name, Sales, Quantity, Discount, Profit) %>%
  mutate(Audit_Category = "Top Gross Revenue Outlier")

# Inspect top 5 net losses
top_losses <- superstore_clean_stage1 %>%
  arrange(Profit) %>%
  slice(1:5) %>%
  select(Row_ID, Order_ID, Order_Date_Clean, Customer_Name, Category, Sub_Category,
         Product_Name, Sales, Quantity, Discount, Profit) %>%
  mutate(Audit_Category = "Deepest Commercial Loss Outlier")

# Inspect top 5 net profits
top_profits <- superstore_clean_stage1 %>%
  arrange(desc(Profit)) %>%
  slice(1:5) %>%
  select(Row_ID, Order_ID, Order_Date_Clean, Customer_Name, Category, Sub_Category,
         Product_Name, Sales, Quantity, Discount, Profit) %>%
  mutate(Audit_Category = "Top Net Profit Outlier")

extreme_audit <- bind_rows(top_sales, top_losses, top_profits)
write_csv(extreme_audit, file.path("outputs", "tables", "extreme_transactions_audit.csv"))

message("05_outlier_analysis.R executed successfully.")
