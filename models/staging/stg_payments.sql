select
    payment_id,
    claim_id,
    cast(payment_date as date)            as payment_date,
    cast(paid_amount as decimal(12, 2))   as paid_amount
from {{ ref('raw_payments') }}
