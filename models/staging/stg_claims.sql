with source as (
    select * from {{ ref('raw_claims') }}
),

deduplicated as (
    -- the extract contains exact duplicate rows; keep one per claim_id
    select *,
        row_number() over (partition by claim_id order by submission_date) as row_num
    from source
)

select
    claim_id,
    provider_id,
    payer_id,
    cpt_code,
    cast(service_date as date)              as service_date,
    cast(submission_date as date)           as submission_date,
    cast(billed_amount as decimal(12, 2))   as billed_amount,
    cast(allowed_amount as decimal(12, 2))  as allowed_amount,
    lower(trim(claim_status))               as claim_status,
    resubmission_count
from deduplicated
where row_num = 1
