-- Check 1: Null claim_id count
SELECT 
    COUNT(*) as null_claim_id_count
FROM health_claims_dev.silver.claims_clean
WHERE claim_id IS NULL;

-- Check 2: Null claim_amount count
SELECT 
    COUNT(*) as null_amount_count
FROM health_claims_dev.silver.claims_clean
WHERE provider_requested_amount IS NULL;

-- Check 3: Negative amounts
SELECT 
    COUNT(*) as negative_amount_count
FROM health_claims_dev.silver.claims_clean
WHERE provider_requested_amount < 0;

-- Check 4: Duplicate claims
SELECT 
    claim_id,
    COUNT(*) as duplicate_count
FROM health_claims_dev.silver.claims_clean
GROUP BY claim_id
HAVING COUNT(*) > 1;

-- Check 5: Invalid incident types
SELECT 
    COUNT(*) as invalid_incident_count
FROM health_claims_dev.silver.claims_clean
WHERE incident_type NOT IN ('Fall', 'Motor Vehicle', 'Sports Injury', 'Workplace');

-- Check 6: Invalid severity levels
SELECT 
    COUNT(*) as invalid_severity_count
FROM health_claims_dev.silver.claims_clean
WHERE patient_reported_severity NOT IN ('Minor', 'Moderate', 'Severe');

-- Check 7: Future dates
SELECT 
    COUNT(*) as future_date_count
FROM health_claims_dev.silver.claims_clean
WHERE clean_claim_date > CURRENT_DATE();

-- Check 8: Missing plan type
SELECT 
    COUNT(*) as missing_plan_type_count
FROM health_claims_dev.silver.claims_clean
WHERE plan_type IS NULL;

-- Check 9: Data completeness percentage
SELECT 
    (COUNT(CASE WHEN claim_id IS NOT NULL THEN 1 END) * 100.0 / COUNT(*)) as claim_id_completeness,
    (COUNT(CASE WHEN provider_requested_amount IS NOT NULL THEN 1 END) * 100.0 / COUNT(*)) as amount_completeness,
    (COUNT(CASE WHEN incident_type IS NOT NULL THEN 1 END) * 100.0 / COUNT(*)) as incident_completeness
FROM health_claims_dev.silver.claims_clean;

-- Check 10: Quality summary
SELECT 
    'Total Records' as metric,
    COUNT(*) as value
FROM health_claims_dev.silver.claims_clean
UNION ALL
SELECT 
    'Null Claim IDs',
    COUNT(*)
FROM health_claims_dev.silver.claims_clean
WHERE claim_id IS NULL
UNION ALL
SELECT 
    'Null Amounts',
    COUNT(*)
FROM health_claims_dev.silver.claims_clean
WHERE provider_requested_amount IS NULL
UNION ALL
SELECT 
    'Duplicates',
    COUNT(*) - COUNT(DISTINCT claim_id)
FROM health_claims_dev.silver.claims_clean;
