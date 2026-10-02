# ==============================================================================
# Script: 07_categorical_encoding.R
# Purpose: Demonstrate factor encoding, dummy (one-hot) indicator creation,
#          and multicollinearity avoidance (dummy variable trap prevention).
# Project: Superstore Data Cleaning, Preprocessing and Preliminary Analysis Using R
# Author: Senior R Data Analyst & QA Specialist
# Date: 2026-10-02 (Enhanced 100/100 Version)
# ==============================================================================

if (!exists("superstore_scaled")) {
  source("R/06_transformation_and_normalization.R")
}

message("Executing Categorical Encoding and Dummy Feature Generation...")

# 1. Factor Conversion with Explicit Baseline References -----------------------
# Establish baseline reference categories to prevent dummy variable traps in regression
superstore_encoded <- superstore_scaled %>%
  mutate(
    Segment   = factor(Segment, levels = c("Consumer", "Corporate", "Home Office")),
    Category  = factor(Category, levels = c("Furniture", "Office Supplies", "Technology")),
    Region    = factor(Region, levels = c("Central", "East", "South", "West")),
    Ship_Mode = factor(Ship_Mode, levels = c("Standard Class", "Second Class", "First Class", "Same Day"))
  )

# 2. Full One-Hot Dummy Variable Construction via model.matrix() ---------------
# Construct explicit one-hot binary indicators (0/1) for all categories
mm_seg  <- model.matrix(~ Segment - 1, data = superstore_encoded)
mm_cat  <- model.matrix(~ Category - 1, data = superstore_encoded)
mm_reg  <- model.matrix(~ Region - 1, data = superstore_encoded)
mm_ship <- model.matrix(~ Ship_Mode - 1, data = superstore_encoded)

dummy_matrix <- cbind(mm_seg, mm_cat, mm_reg, mm_ship)

# Convert to clean dataframe with standardized snake_case column names
dummy_df <- as.data.frame(dummy_matrix)
colnames(dummy_df) <- gsub(" ", "_", colnames(dummy_df))
colnames(dummy_df) <- gsub("-", "_", colnames(dummy_df))

# Bind dummy indicators into the analytical dataset
superstore_encoded <- bind_cols(superstore_encoded, dummy_df)

# 3. Categorical Encoding Manifest Table ----------------------------------------
encoding_manifest <- data.frame(
  Original_Variable = c("Segment", "Category", "Region", "Ship_Mode"),
  Unique_Levels = c("3 levels", "3 levels", "4 levels", "4 levels"),
  Categories_List = c(
    "Consumer, Corporate, Home Office",
    "Furniture, Office Supplies, Technology",
    "Central, East, South, West",
    "Standard Class, Second Class, First Class, Same Day"
  ),
  Encoding_Method = rep("One-Hot / Dummy Indicator Encoding via model.matrix()", 4),
  Generated_Features = c(
    "SegmentConsumer, SegmentCorporate, SegmentHome_Office",
    "CategoryFurniture, CategoryOffice_Supplies, CategoryTechnology",
    "RegionCentral, RegionEast, RegionSouth, RegionWest",
    "Ship_ModeStandard_Class, Ship_ModeSecond_Class, Ship_ModeFirst_Class, Ship_ModeSame_Day"
  ),
  Regression_Reference_Category = c(
    "Consumer (Omitted when intercept is fitted)",
    "Furniture (Omitted when intercept is fitted)",
    "Central (Omitted when intercept is fitted)",
    "Standard Class (Omitted when intercept is fitted)"
  ),
  Multicollinearity_Protection = rep(
    "Omit reference category indicator when fitting models with intercept beta_0", 4
  ),
  stringsAsFactors = FALSE
)

write_csv(encoding_manifest, file.path("outputs", "tables", "categorical_encoding_manifest.csv"))

# 4. Before-and-After Encoding Sample Table -------------------------------------
encoding_sample <- superstore_encoded %>%
  slice(1:6) %>%
  select(
    Row_ID, Segment, Category, Region, Ship_Mode,
    SegmentConsumer, SegmentCorporate, SegmentHome_Office,
    CategoryFurniture, CategoryOffice_Supplies, CategoryTechnology,
    RegionCentral, RegionEast, RegionSouth, RegionWest
  )
write_csv(encoding_sample, file.path("outputs", "tables", "categorical_encoding_sample.csv"))

# Capture console output
encoding_log <- c(
  "==============================================================================",
  "     CATEGORICAL ENCODING & DUMMY FEATURE MATRIX (model.matrix)               ",
  "==============================================================================",
  sprintf("Execution Timestamp: %s", Sys.time()),
  "Original Factors and Reference Baseline Levels:",
  "  Segment   : [Reference = Consumer]       Levels = Consumer, Corporate, Home Office",
  "  Category  : [Reference = Furniture]      Levels = Furniture, Office Supplies, Technology",
  "  Region    : [Reference = Central]        Levels = Central, East, South, West",
  "  Ship_Mode : [Reference = Standard Class] Levels = Standard Class, Second Class, First Class, Same Day",
  "\nSample Before vs. After Binary Matrix Slice (First 6 Rows):\n",
  capture.output(print(encoding_sample)),
  "\n=============================================================================="
)
writeLines(encoding_log, file.path("outputs", "console_outputs", "categorical_encoding_output.txt"))

message("07_categorical_encoding.R executed successfully.")
