-- Do claims submitted more than 7 days after service get denied more often?
-- Compile with `dbt compile -s late_submission_denials` and run the SQL in target/.
select
    charge_lag_days > 7                                                        as submitted_late,
    count(*)                                                                   as claims,
    round(100.0 * count_if(claim_status = 'denied') / count_if(is_adjudicated), 1) as denial_rate_pct
from {{ ref('fct_claims') }}
group by 1
order by 1
