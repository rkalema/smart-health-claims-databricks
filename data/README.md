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

claim_id,patient_id,incident_type,patient_reported_severity,provider_requested_amount,clean_claim_date,avg_heart_rate,avg_sleep_score,plan_type
CLM-001,P-12345,Fall,Moderate,15000.00,2026-05-15,72.5,68.3,Standard
CLM-002,P-12346,Motor Vehicle,Severe,125000.00,2026-05-16,88.2,45.1,Premium

{
  "event_type": "INSERT",
  "patient_id": "P-12345",
  "encounter_id": "ENC-98765",
  "timestamp": "2026-05-15T14:30:00Z",
  "payload": {
    "diagnosis": "S72.001A",
    "procedure": "27236",
    "provider_npi": "1234567890"
  }
}

Then click **Commit changes** again!
