-- Claim Adjudication Rules

CREATE OR REPLACE FUNCTION is_high_value_claim(claim_amount DECIMAL(10,2))
RETURNS BOOLEAN
RETURN claim_amount > 50000;

CREATE OR REPLACE FUNCTION is_valid_npi(npi STRING)
RETURNS BOOLEAN
RETURN npi RLIKE '^[0-9]{10}$';

CREATE OR REPLACE FUNCTION calculate_allowed_amount(
    billed_amount DECIMAL(10,2),
    plan_type STRING
)
RETURNS DECIMAL(10,2)
RETURN CASE
    WHEN plan_type = 'Premium' THEN billed_amount * 0.90
    WHEN plan_type = 'Standard' THEN billed_amount * 0.80
    WHEN plan_type = 'Basic' THEN billed_amount * 0.70
    ELSE billed_amount * 0.50
END;

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
    WHEN NOT has_coverage THEN 'DENIED'
    WHEN claim_amount <= 0 THEN 'DENIED'
    ELSE 'APPROVED'
END;

CREATE OR REPLACE FUNCTION requires_manual_review(
    claim_amount DECIMAL(10,2),
    incident_type STRING,
    severity STRING
)
RETURNS BOOLEAN
RETURN claim_amount > 100000
    OR incident_type IN ('Workplace', 'Motor Vehicle')
    OR severity = 'Severe';

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
