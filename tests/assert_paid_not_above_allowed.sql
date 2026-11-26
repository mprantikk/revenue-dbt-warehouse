-- A payer should never pay more than the contracted allowed amount.
select claim_id, paid_amount, allowed_amount
from {{ ref('fct_claims') }}
where paid_amount > allowed_amount
