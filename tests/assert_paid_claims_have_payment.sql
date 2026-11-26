-- Every paid claim must have a remittance, and no unpaid claim may have one.
select claim_id, claim_status, payment_date
from {{ ref('fct_claims') }}
where (claim_status = 'paid' and payment_date is null)
   or (claim_status <> 'paid' and payment_date is not null)
