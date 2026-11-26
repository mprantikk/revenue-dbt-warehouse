-- Which denial codes cost the most, and are they preventable (CO) or not (PR)?
select
    denial_code,
    denial_reason,
    denial_group,
    denial_group = 'CO'                                    as is_preventable,
    count(*)                                               as denials,
    sum(billed_amount)                                     as billed_amount_at_risk,
    round(100.0 * count(*) / sum(count(*)) over (), 1)     as share_of_denials_pct
from {{ ref('fct_claims') }}
where claim_status = 'denied'
group by 1, 2, 3
order by billed_amount_at_risk desc
