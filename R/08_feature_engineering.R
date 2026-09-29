# ==============================================================================
# Script: 08_feature_engineering.R
# Purpose: Derive mathematically sound and commercially meaningful business
#          features across temporal, operational, financial, and pricing dimensions.
#          Export final cleaned and analysis-ready datasets.
# Project: Superstore Data Cleaning, Preprocessing and Preliminary Analysis Using R
# Author: Senior R Data Analyst & QA Specialist
# Date: 2026-09-29
# ==============================================================================

if (!exists("superstore_encoded")) {
  source("R/07_categorical_encoding.R")
}

message("Executing Feature Engineering and Final Dataset Serialization...")

# 1. Feature Engineering Pipeline ----------------------------------------------
superstore_featured <- superstore_encoded %>%
  mutate(
    # Financial metrics
    Profit_Margin = round(ifelse(Sales > 0, (Profit / Sales) * 100, NA_real_), 2),
    Is_Profitable = Profit >= 0,
    
    # Temporal attributes
    Order_Year        = lubridate::year(Order_Date_Clean),
    Order_Month       = lubridate::month(Order_Date_Clean),
    Order_Month_Name  = factor(month.abb[Order_Month], levels = month.abb, ordered = TRUE),
    Order_Quarter     = paste0("Q", lubridate::quarter(Order_Date_Clean)),
    Order_Day_of_Week = factor(
      weekdays(Order_Date_Clean),
      levels = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"),
      ordered = TRUE
    ),
    Order_Year_Month  = format(Order_Date_Clean, "%Y-%m"),
    Order_YM_Date     = as.Date(paste0(Order_Year_Month, "-01")),
    
    # Discretized pricing & volume tiers
    Discount_Band = cut(
      Discount,
      breaks = c(-Inf, 0.001, 0.101, 0.201, 0.301, 0.501, 0.801),
      labels = c("0% (List Price)", "1-10%", "11-20%", "21-30%", "31-50%", "51-80%"),
      right = FALSE
    ),
    Order_Value_Tier = cut(
      Sales,
      breaks = c(0, 25, 100, 500, Inf),
      labels = c("Micro (<$25)", "Medium ($25-$100)", "High ($100-$500)", "Enterprise (>$500)"),
      right = TRUE
    )
  )

# 2. Separate Interpretable vs Analysis-Ready Datasets -------------------------
# A. Interpretable Cleaned Dataset (for reporting, visualization, and human auditing)
superstore_cleaned <- superstore_featured %>%
  select(
    Row_ID, Order_ID, Order_Date = Order_Date_Clean, Ship_Date = Ship_Date_Clean,
    Shipping_Days, Ship_Mode,
    Order_Year, Order_Month, Order_Month_Name, Order_Quarter, Order_Day_of_Week, Order_Year_Month, Order_YM_Date,
    Customer_ID, Customer_Name, Segment,
    Country, City, State, Postal_Code = Postal_Code_Clean, Region,
    Product_ID, Category, Sub_Category, Product_Name,
    Sales, Quantity, Discount, Profit, Profit_Margin, Is_Profitable,
    Discount_Band, Order_Value_Tier
  )

# B. Analysis-Ready Dataset (retains normalized, standardized, and dummy indicators)
superstore_analysis_ready <- superstore_featured

# 3. Export Processed Datasets -------------------------------------------------
write_csv(superstore_cleaned, file.path("data", "processed", "superstore_cleaned.csv"))
saveRDS(superstore_cleaned, file.path("data", "processed", "superstore_cleaned.rds"))

write_csv(superstore_analysis_ready, file.path("data", "processed", "superstore_analysis_ready.csv"))
saveRDS(superstore_analysis_ready, file.path("data", "processed", "superstore_analysis_ready.rds"))

# 4. Feature Engineering Manifest Table ----------------------------------------
fe_manifest <- data.frame(
  Feature_Name = c(
    "Shipping_Days", "Profit_Margin", "Is_Profitable", "Order_Year", "Order_Month",
    "Order_Month_Name", "Order_Quarter", "Order_Day_of_Week", "Order_Year_Month",
    "Discount_Band", "Order_Value_Tier", "Sales_MinMax / ZScore", "Profit_MinMax / ZScore"
  ),
  Formula_Definition = c(
    "as.numeric(difftime(Ship_Date, Order_Date, units = 'days'))",
    "(Profit / Sales) * 100",
    "Profit >= 0",
    "lubridate::year(Order_Date)",
    "lubridate::month(Order_Date)",
    "factor(month.abb[Order_Month], levels = month.abb)",
    "paste0('Q', lubridate::quarter(Order_Date))",
    "weekdays(Order_Date) with Monday-Sunday ordering",
    "format(Order_Date, '%Y-%m')",
    "cut(Discount, [0, 0.1, 0.2, 0.3, 0.5, 0.8])",
    "cut(Sales, [0, 25, 100, 500, Inf])",
    "Min-Max rescaling [0, 1] & Z-score (x - mean)/sd",
    "Min-Max rescaling [0, 1] & Z-score (x - mean)/sd"
  ),
  Analytical_Rationale = c(
    "Quantify logistics fulfillment speed and SLA adherence",
    "Measure return per sales dollar at the line-item transaction level",
    "Binary classification target indicating commercial profitability",
    "Enable annual growth and macro trend benchmarking (2011-2014)",
    "Enable seasonal cycle and monthly pattern decomposition",
    "Ensure correct chronological plotting without alphabetical alphabetical distortion",
    "Evaluate quarterly corporate purchasing and fiscal cycles",
    "Analyze intra-week purchasing behavior",
    "Provide uniform temporal anchors for chronological line charts",
    "Evaluate non-linear discounting thresholds and margin collapse",
    "Segment transactions by revenue scale (Micro to Enterprise)",
    "Rescale continuous predictors for distance-based ML algorithms",
    "Rescale continuous financial targets for regression modeling"
  ),
  Variable_Scope = c(
    "Operational", "Financial", "Financial", "Temporal", "Temporal",
    "Temporal", "Temporal", "Temporal", "Temporal", "Commercial",
    "Commercial", "Machine Learning Ready", "Machine Learning Ready"
  ),
  stringsAsFactors = FALSE
)

write_csv(fe_manifest, file.path("outputs", "tables", "feature_engineering_dictionary.csv"))

message("Cleaned datasets exported to data/processed/.")
message("08_feature_engineering.R executed successfully.")
