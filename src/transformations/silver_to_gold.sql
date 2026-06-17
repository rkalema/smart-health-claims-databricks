-- Gold Layer Transformations

-- Table 1: Claims Summary by Severity and Plan Type
CREATE OR REPLACE TABLE health_claims_dev.gold.claims_summary
AS
SELECT 
    patient_reported_severity,
    plan_type,
    COUNT(*) as total_claims,
    AVG(provider_requested_amount) as avg_claim_amount,
    SUM(provider_requested_amount) as total_amount,
    MIN(provider_requested_amount) as min_claim_amount,
    MAX(provider_requested_amount) as max_claim_amount
FROM health_claims_dev.silver.claims_clean
GROUP BY patient_reported_severity, plan_type
ORDER BY total_claims DESC;

-- Table 2: Claims Analytics by Incident Type
CREATE OR REPLACE TABLE health_claims_dev.gold.claims_analytics
AS
SELECT 
    incident_type,
    plan_type,
    patient_reported_severity,
    claim_id,
    provider_requested_amount,
    avg_heart_rate,
    avg_sleep_score,
    clean_claim_date
FROM health_claims_dev.silver.claims_clean
ORDER BY clean_claim_date DESC;

-- Table 3: Daily Claim Trends
CREATE OR REPLACE TABLE health_claims_dev.gold.daily_claim_trends
AS
SELECT 
    clean_claim_date,
    plan_type,
    COUNT(*) as daily_claim_count,
    SUM(provider_requested_amount) as total_amount,
    AVG(provider_requested_amount) as avg_daily_amount
FROM health_claims_dev.silver.claims_clean
GROUP BY clean_claim_date, plan_type
ORDER BY clean_claim_date ASC;

-- Table 4: Incident Type Summary
CREATE OR REPLACE TABLE health_claims_dev.gold.incident_summary
AS
SELECT 
    incident_type,
    COUNT(*) as claim_count,
    AVG(provider_requested_amount) as avg_amount,
    SUM(provider_requested_amount) as total_amount,
    COUNT(DISTINCT patient_id_hash) as unique_patients
FROM health_claims_dev.silver.claims_clean
GROUP BY incident_type
ORDER BY claim_count DESC;

-- Table 5: Severity Metrics
CREATE OR REPLACE TABLE health_claims_dev.gold.severity_metrics
AS
SELECT 
    patient_reported_severity,
    COUNT(*) as total_claims,
    AVG(provider_requested_amount) as avg_claim_amount,
    AVG(avg_heart_rate) as avg_heart_rate,
    AVG(avg_sleep_score) as avg_sleep_score,
    COUNT(DISTINCT incident_type) as incident_type_diversity
FROM health_claims_dev.silver.claims_clean
GROUP BY patient_reported_severity
ORDER BY 
    CASE patient_reported_severity
        WHEN 'Minor' THEN 1
        WHEN 'Moderate' THEN 2
        WHEN 'Severe' THEN 3
    END;
