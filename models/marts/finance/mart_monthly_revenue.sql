-- Monthly billed vs collected with a rolling 3-month collection rate.
with monthly as (
    select
        service_month,
        count(*)            as claims,
        sum(billed_amount)  as billed_amount,
        sum(allowed_amount) as allowed_amount,
        sum(paid_amount)    as collected_amount
    from {{ ref('fct_claims') }}
    group by 1
)

select
    service_month,
    claims,
    billed_amount,
    collected_amount,
    round(100.0 * collected_amount / nullif(allowed_amount, 0), 1) as collection_rate_pct,
    round(100.0 * sum(collected_amount) over w3 / nullif(sum(allowed_amount) over w3, 0), 1)
        as rolling_3m_collection_rate_pct,
    round(100.0 * (collected_amount - lag(collected_amount) over (order by service_month))
          / nullif(lag(collected_amount) over (order by service_month), 0), 1)
        as collected_mom_change_pct
from monthly
window w3 as (order by service_month rows between 2 preceding and current row)
order by service_month
