# Data Directory

## Overview
This directory contains sample datasets and data generation scripts used for the development and testing of the Health Claims Analytics pipeline.

**Note:** Actual production data is stored in Databricks Unity Catalog tables (`health_claims_dev`), not in this repository. This folder only contains synthetic test data and utilities.

---

## Directory Structure

```text
data/
── README.md                    # This file
├── generate_data.py             # Script to generate synthetic test data
├── raw/                         # Raw source files (CSV/JSON) - NOT committed to git
├── processed/                   # Processed files for local testing
── schemas/                     # JSON schema files for validation
