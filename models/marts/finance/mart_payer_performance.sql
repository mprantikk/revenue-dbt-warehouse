-- The five core RCM KPIs per payer: the table behind a payer scorecard.
with claims as (
    select * from {{ ref('fct_claims') }}
),
payers as (
    select * from {{ ref('dim_payers') }}
)

select
    p.payer_name,
    p.payer_type,
    count(*)                                                                   as total_claims,
    round(100.0 * count_if(claim_status = 'denied') / nullif(count_if(is_adjudicated), 0), 1)
                                                                               as denial_rate_pct,
    round(100.0 * count_if(is_clean_claim) / nullif(count_if(is_adjudicated), 0), 1)
                                                                               as clean_claim_rate_pct,
    round(avg(days_to_payment), 1)                                             as avg_days_to_payment,
    round(avg(charge_lag_days), 1)                                             as avg_charge_lag_days,
    round(100.0 * sum(paid_amount) filter (where claim_status = 'paid')
          / nullif(sum(allowed_amount) filter (where claim_status = 'paid'), 0), 1)
                                                                               as net_collection_rate_pct,
    sum(billed_amount)                                                         as billed_amount,
    sum(paid_amount)                                                           as collected_amount
from claims c
join payers p using (payer_id)
group by 1, 2
