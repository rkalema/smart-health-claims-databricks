-- Claim Adjudication Rules
-- Applied during Silver layer transformation

-- Rule 1: Flag high-value claims
CREATE OR REPLACE FUNCTION is_high_value_claim(claim_amount DECIMAL(10,2))
RETURNS BOOLEAN
RETURN claim_amount > 50000;

-- Rule 2: Validate provider NPI format
CREATE OR REPLACE FUNCTION is_valid_npi(npi STRING)
RETURNS BOOLEAN
RETURN npi RLIKE '^[0-9]{10}$';

-- Rule 3: Check duplicate claim
CREATE OR REPLACE FUNCTION is_duplicate_claim(
    claim_id STRING,
    patient_id STRING,
    service_date DATE
)
RETURNS BOOLEAN
RETURN EXISTS (
    SELECT 1 FROM health_claims_dev.silver.claims_clean
    WHERE claim_id = claim_id
    AND patient_id = patient_id
    AND service_date = service_date
);

-- Rule 4: Calculate allowed amount
CREATE OR REPLACE FUNCTION calculate_allowed_amount(
    billed_amount DECIMAL(10,2),
    plan_type STRING,
    procedure_code STRING
)
RETURNS DECIMAL(10,2)
RETURN CASE
    WHEN plan_type = 'Premium' THEN billed_amount * 0.90
    WHEN plan_type = 'Standard' THEN billed_amount * 0.80
    WHEN plan_type = 'Basic' THEN billed_amount * 0.70
    ELSE billed_amount * 0.50
END;

-- Rule 5: Determine claim status
CREATE OR REPLACE FUNCTION determine_claim_status(
    is_valid BOOLEAN,
    is_duplicate BOOLEAN,
    has_coverage BOOLEAN,
    claim_amount DECIMAL(10,2)
)
RETURNS STRING
RETURN CASE
    WHEN NOT is_valid THEN 'REJECTED'
    WHEN is_duplicate THEN 'DUPLICATE'
    WHEN NOT has_coverage THEN 'DENIED_NO_COVERAGE'
    WHEN claim_amount <= 0 THEN 'DENIED_ZERO_AMOUNT'
    ELSE 'APPROVED'
END;

-- Rule 6: Flag for review
CREATE OR REPLACE FUNCTION requires_manual_review(
    claim_amount DECIMAL(10,2),
    incident_type STRING,
    severity STRING
)
RETURNS BOOLEAN
RETURN claim_amount > 100000
    OR incident_type IN ('Workplace', 'Motor Vehicle')
    OR severity = 'Severe';

-- Rule 7: Calculate patient responsibility
CREATE OR REPLACE FUNCTION calculate_patient_responsibility(
    allowed_amount DECIMAL(10,2),
    deductible_remaining DECIMAL(10,2),
    coinsurance_rate DECIMAL(5,2),
    copay DECIMAL(10,2)
)
RETURNS DECIMAL(10,2)
RETURN CASE
    WHEN deductible_remaining > 0 THEN LEAST(deductible_remaining, allowed_amount)
    ELSE (allowed_amount * coinsurance_rate) + copay
END;

-- Rule 8: Validate service date
CREATE OR REPLACE FUNCTION is_valid_service_date(service_date DATE)
RETURNS BOOLEAN
RETURN service_date <= CURRENT_DATE()
    AND service_date >= DATE_SUB(CURRENT_DATE(), 365);

-- Rule 9: Check pre-authorization requirement
CREATE OR REPLACE FUNCTION requires_preauth(procedure_code STRING)
RETURNS BOOLEAN
RETURN procedure_code LIKE 'S%' OR procedure_code LIKE 'Q%';

-- Rule 10: Apply bundling rules
CREATE OR REPLACE FUNCTION apply_bundling(
    procedure_codes ARRAY<STRING>,
    total_amount DECIMAL(10,2)
)
RETURNS DECIMAL(10,2)
RETURN CASE
    WHEN array_contains(procedure_codes, '99213') AND array_contains(procedure_codes, '99214')
    THEN total_amount * 0.85
    ELSE total_amount
END;
