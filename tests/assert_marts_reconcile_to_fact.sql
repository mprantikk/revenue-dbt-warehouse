-- Totals must not drift between the fact table and the marts built from it.
with fact as (
    select sum(paid_amount) as collected, count(*) as claims from {{ ref('fct_claims') }}
),
by_payer as (
    select sum(collected_amount) as collected, sum(total_claims) as claims
    from {{ ref('mart_payer_performance') }}
),
by_month as (
    select sum(collected_amount) as collected, sum(claims) as claims
    from {{ ref('mart_monthly_revenue') }}
)
select *
from fact, by_payer, by_month
where fact.collected <> by_payer.collected
   or fact.collected <> by_month.collected
   or fact.claims <> by_payer.claims
   or fact.claims <> by_month.claims
