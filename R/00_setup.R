# ==============================================================================
# Script: 00_setup.R
# Purpose: Initialize environment, load/install dependencies, configure global
#          options, define directory constants, and establish ggplot2 theme.
# Project: Superstore Data Cleaning, Preprocessing and Preliminary Analysis Using R
# Author: Senior R Data Analyst & QA Specialist
# Date: 2026-09-29
# ==============================================================================

# 1. Global R Options & Reproducibility -----------------------------------------
options(scipen = 999)      # Suppress scientific notation for clean financial output
options(digits = 4)        # Standardize decimal precision
set.seed(42)               # Enforce absolute reproducibility across all stochastic processes

# 2. Package Management --------------------------------------------------------
required_packages <- c(
  "readr",       # Fast, tidy tabular data import
  "dplyr",       # Core data wrangling and aggregation
  "tidyr",       # Tidy data pivoting and reshaping
  "lubridate",   # Robust date parsing and arithmetic
  "ggplot2",     # Grammar of Graphics data visualization
  "scales",      # Currency, percentage, and logarithmic axis formatting
  "forcats",     # Factor reordering for visual clarity
  "patchwork"    # Multi-panel composite chart construction
)

load_packages <- function(pkgs) {
  missing_pkgs <- pkgs[!(pkgs %in% installed.packages()[, "Package"])]
  if (length(missing_pkgs) > 0) {
    message("Installing missing packages: ", paste(missing_pkgs, collapse = ", "))
    install.packages(missing_pkgs, repos = "https://cloud.r-project.org", quiet = TRUE)
  }
  for (p in pkgs) {
    suppressPackageStartupMessages(library(p, character.only = TRUE))
  }
  message("All required R packages loaded successfully.")
}

load_packages(required_packages)

# 3. Directory Structure Verification ------------------------------------------
base_dirs <- c(
  file.path("data", "raw"),
  file.path("data", "processed"),
  "R",
  "scripts",
  file.path("outputs", "tables"),
  file.path("outputs", "figures"),
  file.path("outputs", "diagnostics"),
  file.path("outputs", "statistics"),
  file.path("outputs", "console_outputs"),
  "screenshots",
  "report",
  "docs"
)

for (d in base_dirs) {
  if (!dir.exists(d)) {
    dir.create(d, recursive = TRUE, showWarnings = FALSE)
  }
}

# 4. Standardized ggplot2 Visualization Theme ----------------------------------
theme_superstore_eda <- function(base_size = 11, base_family = "sans") {
  theme_minimal(base_size = base_size, base_family = base_family) +
    theme(
      plot.title = element_text(face = "bold", size = rel(1.2), color = "#1D3557", margin = margin(b = 6)),
      plot.subtitle = element_text(size = rel(0.95), color = "#457B9D", margin = margin(b = 10)),
      plot.caption = element_text(size = rel(0.8), color = "#6C757D", hjust = 0, margin = margin(t = 10)),
      axis.title = element_text(face = "bold", size = rel(0.9), color = "#1D3557"),
      axis.text = element_text(size = rel(0.85), color = "#2B2D42"),
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_line(color = "#E9ECEF", linewidth = 0.4),
      panel.grid.major.y = element_line(color = "#E9ECEF", linewidth = 0.4),
      legend.position = "bottom",
      legend.title = element_text(face = "bold", size = rel(0.85), color = "#1D3557"),
      legend.text = element_text(size = rel(0.8), color = "#2B2D42"),
      plot.margin = margin(15, 15, 15, 15),
      strip.background = element_rect(fill = "#EBF2FA", color = NA),
      strip.text = element_text(face = "bold", color = "#1D3557", size = rel(0.9))
    )
}

# Palette constants
pal_navy     <- "#1D3557"
pal_slate    <- "#457B9D"
pal_teal     <- "#2A9D8F"
pal_coral    <- "#E76F51"
pal_crimson  <- "#D90429"
pal_emerald  <- "#2D6A4F"
pal_charcoal <- "#2B2D42"

pal_category <- c(
  "Furniture"       = "#E07A5F",
  "Office Supplies" = "#3D5A80",
  "Technology"      = "#2B7A78"
)

message("00_setup.R initialized successfully.")
