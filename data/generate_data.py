import pandas as pd
import numpy as np
import json
import uuid
from datetime import datetime, timedelta
import os


np.random.seed(42)


os.makedirs('data/output', exist_ok=True)

print("🏥 Generating synthetic health claims data...")


num_patients = 100
patients = pd.DataFrame({
    'patient_id': [f'PT-{str(uuid.uuid4())[:8].upper()}' for _ in range(num_patients)],
    'first_name': np.random.choice(['John', 'Jane', 'Michael', 'Sarah', 'David', 'Emily', 'Robert', 'Lisa'], num_patients),
    'last_name': np.random.choice(['Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis'], num_patients),
    'date_of_birth': [(datetime.now() - timedelta(days=np.random.randint(365*20, 365*80))).strftime('%Y-%m-%d') for _ in range(num_patients)],
    'primary_care_physician': np.random.choice(['Dr. A. Smith', 'Dr. B. Johnson', 'Dr. C. Williams', 'Dr. D. Brown'], num_patients)
})
patients.to_csv('data/output/patients.csv', index=False)
print(f"✅ Generated {num_patients} patients")


policies = pd.DataFrame({
    'policy_id': [f'POL-{str(uuid.uuid4())[:8].upper()}' for _ in range(num_patients)],
    'patient_id': patients['patient_id'],
    'plan_type': np.random.choice(['Basic', 'Standard', 'Premium'], num_patients),
    'coverage_limit': np.random.choice([5000, 15000, 50000], num_patients),
    'is_active': np.random.choice([True, True, True, False], num_patients),
    'effective_date': (datetime.now() - timedelta(days=np.random.randint(30, 365))).strftime('%Y-%m-%d')
})
policies.to_csv('data/output/policies.csv', index=False)
print(f"✅ Generated {num_patients} policies")


num_claims = 150
claims = pd.DataFrame({
    'claim_id': [f'CLM-{str(uuid.uuid4())[:8].upper()}' for _ in range(num_claims)],
    'patient_id': np.random.choice(patients['patient_id'], num_claims),
    'claim_date': [(datetime.now() - timedelta(days=np.random.randint(1, 30))).strftime('%Y-%m-%d') for _ in range(num_claims)],
    'incident_type': np.random.choice(['Fall', 'Motor Vehicle', 'Sports Injury', 'Workplace', 'Other'], num_claims),
    'provider_requested_amount': np.random.randint(500, 45000, num_claims),
    'patient_reported_severity': np.random.choice(['Minor', 'Moderate', 'Severe'], num_claims),
    'image_uploaded': np.random.choice([True, True, True, False], num_claims)
})
claims.to_csv('data/output/claims.csv', index=False)
print(f"✅ Generated {num_claims} claims")


rpm_data = []
for _ in range(50):
    rpm_data.append({
        "patient_id": np.random.choice(patients['patient_id']),
        "timestamp": (datetime.now() - timedelta(hours=np.random.randint(1, 48))).isoformat(),
        "heart_rate_bpm": int(np.random.normal(75, 10)),
        "activity_level": np.random.choice(['Sedentary', 'Light', 'Moderate', 'Active']),
        "sleep_quality_score": int(np.random.randint(40, 95))
    })

with open('data/output/rpm_stream_mock.jsonl', 'w') as f:
    for item in rpm_data:
        f.write(json.dumps(item) + '\n')
print(f"✅ Generated {len(rpm_data)} RPM stream records")

print("\n🎉 All synthetic data generated successfully in data/output/!")
