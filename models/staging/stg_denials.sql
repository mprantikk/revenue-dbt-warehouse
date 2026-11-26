select
    denial_id,
    claim_id,
    cast(denial_date as date)   as denial_date,
    upper(trim(denial_code))    as denial_code,
    denial_reason,
    -- CARC group code: CO = contractual (provider can fix), PR = patient responsibility
    split_part(upper(trim(denial_code)), '-', 1) as denial_group
from {{ ref('raw_denials') }}
