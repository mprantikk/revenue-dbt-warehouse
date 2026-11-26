-- Open (pending) claims bucketed by age as of var('as_of_date').
with open_claims as (
    select
        claim_id,
        payer_id,
        billed_amount,
        {{ days_between('submission_date', "cast('" ~ var('as_of_date') ~ "' as date)") }} as age_days
    from {{ ref('fct_claims') }}
    where claim_status = 'pending'
)

select
    case
        when age_days <= 30 then '0-30'
        when age_days <= 60 then '31-60'
        when age_days <= 90 then '61-90'
        else '90+'
    end                     as aging_bucket,
    count(*)                as open_claims,
    sum(billed_amount)      as open_billed_amount
from open_claims
group by 1
order by min(age_days)
