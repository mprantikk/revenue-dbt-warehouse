"""Generate the synthetic raw data loaded by `dbt seed`.

Deterministic (fixed seed), so the warehouse numbers in the README are
reproducible. The raw layer is intentionally a little messy (inconsistent
casing and whitespace in names, mixed-case status codes) so the staging
models have real cleaning to do.

    python scripts/generate_data.py
"""

import csv
import random
from datetime import date, timedelta
from pathlib import Path

random.seed(42)
OUT = Path(__file__).resolve().parent.parent / "seeds"

PAYERS = [
    (1, "  BlueStar Health ", "commercial", 30, 0.08),
    (2, "united care plus", "COMMERCIAL", 34, 0.10),
    (3, "Medicare Part B", "medicare", 45, 0.12),
    (4, "MEDICARE ADVANTAGE ONE", "Medicare", 50, 0.14),
    (5, "State Medicaid", "medicaid", 58, 0.17),
    (6, "Self Pay", "self-pay", 70, 0.20),
]
SPECIALTIES = ["Cardiology", "Orthopedics", "Primary Care", "Dermatology", "Radiology", "Pediatrics"]
CITIES = ["Austin", "Denver", "Phoenix", "Atlanta"]
DENIALS = [
    ("CO-16", "Claim lacks information needed for adjudication", 0.24),
    ("CO-11", "Diagnosis inconsistent with procedure", 0.18),
    ("CO-197", "Precertification or authorization absent", 0.16),
    ("CO-97", "Benefit included in another service", 0.14),
    ("PR-1", "Deductible amount", 0.12),
    ("CO-29", "Time limit for filing expired", 0.09),
    ("CO-50", "Non-covered service", 0.07),
]
CPT = {"99213": 145, "99214": 210, "93000": 85, "73721": 620, "71046": 160, "11102": 190, "20610": 260}


def write(name, header, rows):
    with open(OUT / f"{name}.csv", "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(header)
        w.writerows(rows)


def main():
    OUT.mkdir(exist_ok=True)
    write("raw_payers", ["payer_id", "payer_name", "payer_type"], [p[:3] for p in PAYERS])

    providers = []
    for pid in range(1, 25):
        spec = SPECIALTIES[(pid - 1) % len(SPECIALTIES)]
        name = f"Dr. Provider {pid:02d}"
        if pid % 5 == 0:
            name = name.upper() + " "
        providers.append((pid, name, spec, random.choice(CITIES), (pid % 7) / 100))
    write("raw_providers", ["provider_id", "provider_name", "specialty", "city"], [p[:4] for p in providers])

    claims, payments, denials = [], [], []
    start, end = date(2024, 1, 1), date(2025, 12, 31)
    days = (end - start).days
    pay_id = den_id = 0
    for cid in range(1, 4001):
        payer = random.choices(PAYERS, weights=[30, 22, 18, 10, 12, 8])[0]
        prov = random.choice(providers)
        dos = start + timedelta(days=random.randint(0, days))
        lag = max(0, int(random.gauss(4, 2.5)))
        submitted = dos + timedelta(days=lag)
        cpt = random.choice(list(CPT))
        billed = round(CPT[cpt] * random.uniform(0.9, 1.4), 2)
        allowed = round(billed * random.uniform(0.55, 0.85), 2)
        p_deny = payer[4] + prov[4] + (0.05 if lag > 7 else 0)
        resub = 0
        age_days = (date(2026, 1, 31) - submitted).days
        if age_days < 25 and random.random() < 0.6:
            status = random.choice(["pending", "PENDING"])
        elif random.random() < p_deny:
            status = random.choice(["denied", "Denied"])
            den_id += 1
            code = random.choices(DENIALS, weights=[d[2] for d in DENIALS])[0]
            denials.append((den_id, cid, submitted + timedelta(days=random.randint(10, 30)), code[0], code[1]))
        else:
            status = random.choice(["paid", "PAID", "Paid "])
            resub = 1 if random.random() < 0.18 else 0
            pay_days = max(7, int(random.gauss(payer[3] + resub * 15, 8)))
            paid_on = submitted + timedelta(days=pay_days)
            if paid_on > date(2026, 1, 31):
                status = "pending"
            else:
                pay_id += 1
                paid = round(allowed * random.uniform(0.9, 1.0), 2)
                payments.append((pay_id, cid, paid_on, paid))
        claims.append((cid, prov[0], payer[0], cpt, dos, submitted, billed, allowed, status, resub))

    # a handful of exact duplicate claim rows, as real extracts often contain
    claims += [claims[i] for i in (10, 500, 2000)]
    write("raw_claims", ["claim_id", "provider_id", "payer_id", "cpt_code", "service_date",
                         "submission_date", "billed_amount", "allowed_amount", "claim_status",
                         "resubmission_count"], claims)
    write("raw_payments", ["payment_id", "claim_id", "payment_date", "paid_amount"], payments)
    write("raw_denials", ["denial_id", "claim_id", "denial_date", "denial_code", "denial_reason"], denials)
    print(f"claims={len(claims)} payments={len(payments)} denials={len(denials)}")


if __name__ == "__main__":
    main()
