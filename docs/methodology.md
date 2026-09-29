# Technical Methodology: Data Cleaning, Preprocessing and Preliminary Analysis

## 1. Overview and Analytical Architecture
This document details the complete technical methodology implemented in the Superstore data cleaning, preprocessing, and preliminary analysis project. The workflow adheres to modern reproducible data science standards, moving systematically from raw data ingestion and structural auditing to data quality repair, non-parametric outlier detection, feature rescaling, categorical encoding, feature engineering, exploratory data analysis, and bivariate correlation modeling.

---

## 2. Ingestion and Structural Auditing
The raw dataset is ingested from `data/raw/superstore_raw.csv` using `readr::read_csv()` with explicit `latin1` encoding to guarantee clean handling of commercial character strings. Initial structural verification confirms 9,994 transaction line items across 21 raw variables. Console diagnostics are captured via native R functions:
* `dim()`, `nrow()`, `ncol()`: Dimensional verification.
* `names()`, `glimpse()`: Variable naming and column sequence auditing.
* `str()`: Variable storage types (integer, numeric, character).
* `summary()`: Univariate parametric distributions and initial range boundaries.

---

## 3. Data Quality and Completeness Auditing
Data quality is assessed across completeness, uniqueness, consistency, and domain validity:
1. **Missingness:** Evaluated via vectorized `colSums(is.na())` and `rowSums(is.na())`. The dataset exhibits 100% empirical completeness (0 missing cells across 209,874 matrix elements). Theoretical missingness mechanisms (MCAR, MAR, MNAR) and imputation strategies (mean, median, mode, MICE, KNN) are benchmarked methodologically.
2. **Deduplication:** Evaluated via `duplicated()`. Exactly 0 duplicate rows exist. Repeated `Order ID` instances (4,985 lines across 5,009 unique orders) represent legitimate multi-SKU purchasing baskets.
3. **Postal Code Repair:** Numerical storage dropped leading zeroes for northeastern states (e.g. `5408` for Burlington, VT). Padded to standard 5-digit strings via `sprintf("%05s", as.character(Postal_Code))`.
4. **String Trimming:** Applied `trimws()` across all descriptive character columns to eliminate trailing and leading whitespace corruption.
5. **Date Harmonization:** Raw strings formatted as `DD-MM-YYYY` parsed into native Date objects via `lubridate::dmy()`. Evaluated shipping durations (`Ship Date - Order Date`), confirming 100% logical compliance with 0 negative shipping days.

---

## 4. Outlier Analysis and Treatment Decisions
Outlier detection deploys Tukey's non-parametric Interquartile Range ($1.5 \times \text{IQR}$) fencing method:
$$\text{IQR} = Q_3 - Q_1$$
$$\text{Lower Fence} = Q_1 - 1.5 \times \text{IQR}, \quad \text{Upper Fence} = Q_3 + 1.5 \times \text{IQR}$$

* **Sales:** Lower Fence = -$271.71, Upper Fence = $498.93. 1,167 statistical outliers (11.68%) detected.
* **Profit:** Lower Fence = -$39.72, Upper Fence = $70.82. 1,881 statistical outliers (18.82%) detected.
* **Discount:** Lower Fence = -0.30, Upper Fence = 0.50. 856 statistical outliers (8.57%) detected.
* **Quantity:** Lower Fence = -2.50, Upper Fence = 9.50. 170 statistical outliers (1.70%) detected.
* **Shipping Days:** Lower Fence = 0.00, Upper Fence = 8.00. Exactly 0 outliers detected.

**Treatment Justification:** Extreme values were retained 100% in the analytical dataset. Forensic examination confirmed that all extreme values represent genuine, high-value commercial transactions (e.g., enterprise videoconferencing units, heavy copiers, or deep clearance discounts) rather than measurement errors. Removing them would falsely bias enterprise sales and profit metrics.

---

## 5. Normalization and Standardization
To support machine learning algorithms, continuous numerical predictors (`Sales`, `Profit`, `Discount`, `Quantity`, `Shipping_Days`) were rescaled:
1. **Min-Max Normalization:** Rescaling values to the closed interval $[0, 1]$:
   $$x_{\text{norm}} = \frac{x - \min(x)}{\max(x) - \min(x)}$$
2. **Z-Score Standardization:** Rescaling values to zero mean and unit variance ($\mathcal{N}(0, 1)$):
   $$z = \frac{x - \mu}{\sigma}$$
3. **Logarithmic Scaling:** Due to severe positive right-skewness, `Sales` was transformed via $y = \log_{10}(\text{Sales})$, and `Profit` was transformed via signed logarithm $y = \text{sign}(\text{Profit}) \times \log_{10}(|\text{Profit}| + 1)$.

Arbitrary identifiers (`Row ID`, `Order ID`, `Customer ID`) and spatial codes (`Postal Code`) were strictly excluded from rescaling.

---

## 6. Categorical Encoding
Categorical predictors were transformed using two complementary methodologies:
1. **Ordered Factor Encoding:** Factored with business-aligned reference levels for exploratory analysis and ANOVA modeling:
   * `Segment`: Baseline = `Consumer`
   * `Category`: Baseline = `Furniture`
   * `Region`: Baseline = `Central`
   * `Ship Mode`: Baseline = `Standard Class`
2. **One-Hot Dummy Variable Encoding:** Generated via `model.matrix(~ Segment + Category + Region + Ship_Mode - 1)` to produce 14 binary (0/1) indicators for machine learning feature spaces. Multi-collinearity avoidance (dummy variable trap prevention) is explicitly documented.

---

## 7. Feature Engineering
Derived features were constructed across four operational dimensions:
* **Logistics:** `Shipping_Days` ($\text{Ship Date} - \text{Order Date}$).
* **Financial:** `Profit_Margin` ($(\text{Profit} / \text{Sales}) \times 100$) and `Is_Profitable` ($\text{Profit} \ge 0$).
* **Temporal:** `Order_Year`, `Order_Month`, `Order_Month_Name`, `Order_Quarter`, `Order_Day_of_Week`, `Order_Year_Month`, `Order_YM_Date`.
* **Commercial Tiers:** `Discount_Band` (6 discrete brackets) and `Order_Value_Tier` (Micro, Medium, High, Enterprise).

---

## 8. Correlation and Statistical Association
Bivariate associations were evaluated using parametric Pearson linear correlation ($r$) and non-parametric Spearman rank correlation ($\rho$):
* **Significance Testing:** Evaluated via `cor.test()` with 95% confidence intervals and exact $p$-values.
* **Key Observations:**
  * Discount vs Profit: $r = -0.2195$ ($p < 0.0001$), $\rho = -0.5434$ ($p < 0.0001$). Strong monotonic profit deterioration above 20% discount.
  * Sales vs Profit: $r = +0.4791$ ($p < 0.0001$), $\rho = +0.3341$ ($p < 0.0001$). Moderate positive linear association with heteroscedastic dispersion.
* **Association vs Causation:** Emphasized that correlation quantifies observed statistical co-occurrence rather than direct causal mechanisms.
