# ==============================================================================
# Script: 09_descriptive_statistics.R
# Purpose: Compute comprehensive parametric and non-parametric descriptive
#          statistics, categorical frequency tables, and grouped cross-tabulations.
# Project: Superstore Data Cleaning, Preprocessing and Preliminary Analysis Using R
# Author: Senior R Data Analyst & QA Specialist
# Date: 2026-09-29
# ==============================================================================

if (!exists("superstore_cleaned")) {
  source("R/08_feature_engineering.R")
}

message("Calculating Comprehensive Descriptive Statistics...")

# 1. Numerical Variables Descriptive Statistics --------------------------------
num_cols <- c("Sales", "Profit", "Quantity", "Discount", "Shipping_Days", "Profit_Margin")

calc_num_desc <- function(df, var_name) {
  x <- df[[var_name]]
  q <- quantile(x, probs = c(0.25, 0.50, 0.75), na.rm = TRUE)
  data.frame(
    Variable = var_name,
    N_Valid  = sum(!is.na(x)),
    Missing  = sum(is.na(x)),
    Mean     = round(mean(x, na.rm = TRUE), 2),
    Median   = round(q[2], 2),
    Std_Dev  = round(sd(x, na.rm = TRUE), 2),
    Variance = round(var(x, na.rm = TRUE), 2),
    Min      = round(min(x, na.rm = TRUE), 2),
    Q1_25    = round(q[1], 2),
    Q3_75    = round(q[3], 2),
    Max      = round(max(x, na.rm = TRUE), 2),
    IQR      = round(q[3] - q[1], 2),
    stringsAsFactors = FALSE
  )
}

num_desc_table <- bind_rows(lapply(num_cols, function(v) calc_num_desc(superstore_cleaned, v)))
write_csv(num_desc_table, file.path("outputs", "tables", "descriptive_statistics_numerical.csv"))

# 2. Categorical Variables Frequency Summaries ---------------------------------
calc_cat_freq <- function(df, var_name) {
  df %>%
    count(.data[[var_name]], name = "Frequency") %>%
    mutate(
      Variable = var_name,
      Percentage = round((Frequency / sum(Frequency)) * 100, 2),
      Category_Level = as.character(.data[[var_name]])
    ) %>%
    select(Variable, Category_Level, Frequency, Percentage)
}

cat_cols <- c("Category", "Region", "Segment", "Ship_Mode", "Discount_Band", "Order_Value_Tier")
cat_freq_table <- bind_rows(lapply(cat_cols, function(v) calc_cat_freq(superstore_cleaned, v)))
write_csv(cat_freq_table, file.path("outputs", "tables", "categorical_frequency_summary.csv"))

# 3. Grouped Cross-Tabulations by Core Business Dimensions --------------------
# 3A. Category Grouped Summary
cat_grouped <- superstore_cleaned %>%
  group_by(Category) %>%
  summarise(
    Total_Sales    = round(sum(Sales), 2),
    Sales_Share    = round((sum(Sales) / sum(superstore_cleaned$Sales)) * 100, 2),
    Total_Profit   = round(sum(Profit), 2),
    Profit_Share   = round((sum(Profit) / sum(superstore_cleaned$Profit)) * 100, 2),
    Avg_Sales      = round(mean(Sales), 2),
    Avg_Profit     = round(mean(Profit), 2),
    Avg_Discount   = round(mean(Discount) * 100, 2),
    Overall_Margin = round((sum(Profit) / sum(Sales)) * 100, 2),
    Total_Orders   = n_distinct(Order_ID),
    Line_Items     = n(),
    .groups = "drop"
  )
write_csv(cat_grouped, file.path("outputs", "tables", "category_grouped_summary.csv"))

# 3B. Regional Grouped Summary
reg_grouped <- superstore_cleaned %>%
  group_by(Region) %>%
  summarise(
    Total_Sales    = round(sum(Sales), 2),
    Sales_Share    = round((sum(Sales) / sum(superstore_cleaned$Sales)) * 100, 2),
    Total_Profit   = round(sum(Profit), 2),
    Profit_Share   = round((sum(Profit) / sum(superstore_cleaned$Profit)) * 100, 2),
    Avg_Sales      = round(mean(Sales), 2),
    Avg_Profit     = round(mean(Profit), 2),
    Avg_Discount   = round(mean(Discount) * 100, 2),
    Overall_Margin = round((sum(Profit) / sum(Sales)) * 100, 2),
    Total_Orders   = n_distinct(Order_ID),
    Line_Items     = n(),
    .groups = "drop"
  )
write_csv(reg_grouped, file.path("outputs", "tables", "region_grouped_summary.csv"))

# 3C. Segment Grouped Summary
seg_grouped <- superstore_cleaned %>%
  group_by(Segment) %>%
  summarise(
    Total_Sales    = round(sum(Sales), 2),
    Sales_Share    = round((sum(Sales) / sum(superstore_cleaned$Sales)) * 100, 2),
    Total_Profit   = round(sum(Profit), 2),
    Profit_Share   = round((sum(Profit) / sum(superstore_cleaned$Profit)) * 100, 2),
    Avg_Sales      = round(mean(Sales), 2),
    Avg_Profit     = round(mean(Profit), 2),
    Avg_Discount   = round(mean(Discount) * 100, 2),
    Overall_Margin = round((sum(Profit) / sum(Sales)) * 100, 2),
    Total_Orders   = n_distinct(Order_ID),
    Line_Items     = n(),
    .groups = "drop"
  )
write_csv(seg_grouped, file.path("outputs", "tables", "segment_grouped_summary.csv"))

# 3D. Sub-Category Grouped Summary
subcat_grouped <- superstore_cleaned %>%
  group_by(Category, Sub_Category) %>%
  summarise(
    Total_Sales    = round(sum(Sales), 2),
    Total_Profit   = round(sum(Profit), 2),
    Avg_Sales      = round(mean(Sales), 2),
    Avg_Profit     = round(mean(Profit), 2),
    Avg_Discount   = round(mean(Discount) * 100, 2),
    Overall_Margin = round((sum(Profit) / sum(Sales)) * 100, 2),
    Total_Quantity = sum(Quantity),
    Total_Orders   = n_distinct(Order_ID),
    Line_Items     = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(Total_Profit))
write_csv(subcat_grouped, file.path("outputs", "tables", "subcategory_grouped_summary.csv"))

message("09_descriptive_statistics.R executed successfully.")
