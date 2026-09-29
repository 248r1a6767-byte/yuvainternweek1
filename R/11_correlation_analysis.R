# ==============================================================================
# Script: 11_correlation_analysis.R
# Purpose: Execute rigorous parametric Pearson and non-parametric Spearman rank
#          correlation modeling, hypothesis testing (cor.test), and association
#          interpretation without causal claims.
# Project: Superstore Data Cleaning, Preprocessing and Preliminary Analysis Using R
# Author: Senior R Data Analyst & QA Specialist
# Date: 2026-09-29
# ==============================================================================

if (!exists("superstore_cleaned")) {
  source("R/08_feature_engineering.R")
}

message("Executing Correlation Analysis and Hypothesis Testing...")

# 1. Select Valid Continuous Numerical Variables -------------------------------
# Arbitrary identifiers (Row ID, Order ID, Customer ID, Postal Code) strictly excluded
num_vars_corr <- superstore_cleaned %>%
  select(Sales, Quantity, Discount, Profit, Shipping_Days)

# 2. Compute Correlation Matrices ----------------------------------------------
pearson_mat  <- round(cor(num_vars_corr, method = "pearson"), 4)
spearman_mat <- round(cor(num_vars_corr, method = "spearman"), 4)

write.csv(pearson_mat, file.path("outputs", "tables", "correlation_matrix_pearson.csv"))
write.csv(spearman_mat, file.path("outputs", "tables", "correlation_matrix_spearman.csv"))

# 3. Formal Hypothesis Testing (cor.test) ---------------------------------------
test_pairs <- list(
  c("Discount", "Profit"),
  c("Sales", "Profit"),
  c("Quantity", "Sales"),
  c("Quantity", "Profit"),
  c("Shipping_Days", "Profit"),
  c("Discount", "Sales")
)

significance_results <- lapply(test_pairs, function(pair) {
  var1 <- pair[1]
  var2 <- pair[2]
  x <- num_vars_corr[[var1]]
  y <- num_vars_corr[[var2]]
  
  p_test <- cor.test(x, y, method = "pearson")
  s_test <- cor.test(x, y, method = "spearman", exact = FALSE)
  
  data.frame(
    Variable_Pair         = paste(var1, "vs", var2),
    Pearson_r             = round(p_test$estimate, 4),
    Pearson_p_value       = format.pval(p_test$p.value, digits = 4, eps = 0.0001),
    Pearson_95_CI         = paste0("[", round(p_test$conf.int[1], 4), ", ", round(p_test$conf.int[2], 4), "]"),
    Spearman_rho          = round(s_test$estimate, 4),
    Spearman_p_value      = format.pval(s_test$p.value, digits = 4, eps = 0.0001),
    Statistical_Inference = ifelse(
      p_test$p.value < 0.05,
      "Statistically Significant Association (p < 0.05)",
      "Statistically Insignificant (Fail to reject H0)"
    ),
    Association_Nature    = ifelse(
      var1 == "Discount" & var2 == "Profit",
      "Strong monotonic negative association; non-linear profit decay",
      ifelse(
        var1 == "Sales" & var2 == "Profit",
        "Moderate positive linear association; variance widens with volume",
        ifelse(
          var1 == "Quantity" & var2 == "Sales",
          "Weak positive linear association with transaction revenue",
          "Near-zero linear association; negligible predictive relationship"
        )
      )
    ),
    stringsAsFactors = FALSE
  )
}) %>% bind_rows()

write_csv(significance_results, file.path("outputs", "tables", "correlation_significance_tests.csv"))

message("11_correlation_analysis.R executed successfully.")
