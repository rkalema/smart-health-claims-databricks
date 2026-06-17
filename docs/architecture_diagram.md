```mermaid
graph TB
    subgraph "Data Sources"
        EHR[EHR Systems]
        RPM[Remote Patient Monitoring]
        CLAIMS[Claims Files CSV/JSON]
        IMAGES[Medical Images]
    end

    subgraph "Bronze Layer - Raw Ingestion"
        BRONZE_CLAIMS[(bronze.claims_raw)]
        BRONZE_EHR[(bronze.ehr_cdc_raw)]
        BRONZE_RPM[(bronze.rpm_stream_raw)]
        BRONZE_IMAGES[(bronze.medical_images_raw)]
    end

    subgraph "Silver Layer - Cleaned & Masked"
        SILVER_CLAIMS[(silver.claims_clean)]
        DQ[Data Quality Checks]
        PHI[PHI Masking SHA-256]
    end

    subgraph "Gold Layer - Analytics"
        GOLD_SUMMARY[(gold.claims_summary)]
        GOLD_ANALYTICS[(gold.claims_analytics)]
        GOLD_TRENDS[(gold.daily_claim_trends)]
        GOLD_INCIDENT[(gold.incident_summary)]
    end

    subgraph "Consumption"
        DASHBOARD[Databricks SQL Dashboard]
        ML[ML Models]
        REPORTS[Reports & Alerts]
    end

    CLAIMS --> BRONZE_CLAIMS
    EHR --> BRONZE_EHR
    RPM --> BRONZE_RPM
    IMAGES --> BRONZE_IMAGES

    BRONZE_CLAIMS --> SILVER_CLAIMS
    BRONZE_EHR --> SILVER_CLAIMS
    BRONZE_RPM --> SILVER_CLAIMS
    
    SILVER_CLAIMS --> DQ
    SILVER_CLAIMS --> PHI
    
    SILVER_CLAIMS --> GOLD_SUMMARY
    SILVER_CLAIMS --> GOLD_ANALYTICS
    SILVER_CLAIMS --> GOLD_TRENDS
    SILVER_CLAIMS --> GOLD_INCIDENT

    GOLD_SUMMARY --> DASHBOARD
    GOLD_ANALYTICS --> DASHBOARD
    GOLD_TRENDS --> DASHBOARD
    GOLD_INCIDENT --> DASHBOARD

    GOLD_ANALYTICS --> ML
    DASHBOARD --> REPORTS
