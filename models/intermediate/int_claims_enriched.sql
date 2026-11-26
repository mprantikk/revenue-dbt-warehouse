-- Claim grain, joined to its payment and denial so every mart starts from
-- the same definitions of "paid", "denied", "days to pay" and "clean claim".
with claims as (
    select * from {{ ref('stg_claims') }}
),
payments as (
    select * from {{ ref('stg_payments') }}
),
denials as (
    select * from {{ ref('stg_denials') }}
)

select
    c.claim_id,
    c.provider_id,
    c.payer_id,
    c.cpt_code,
    c.service_date,
    c.submission_date,
    date_trunc('month', c.service_date)                        as service_month,
    c.claim_status,
    c.resubmission_count,
    c.billed_amount,
    c.allowed_amount,
    coalesce(p.paid_amount, 0)                                 as paid_amount,
    p.payment_date,
    d.denial_code,
    d.denial_reason,
    d.denial_group,
    {{ days_between('c.service_date', 'c.submission_date') }}  as charge_lag_days,
    {{ days_between('c.service_date', 'p.payment_date') }}     as days_to_payment,
    c.claim_status in ('paid', 'denied')                       as is_adjudicated,
    c.claim_status = 'paid' and c.resubmission_count = 0       as is_clean_claim
from claims c
left join payments p on p.claim_id = c.claim_id
left join denials  d on d.claim_id = c.claim_id
