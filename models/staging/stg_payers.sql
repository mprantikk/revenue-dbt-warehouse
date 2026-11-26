with source as (
    select *, trim(payer_name) as clean_name
    from {{ ref('raw_payers') }}
)

select
    payer_id,
    -- raw names arrive with stray whitespace and shouting/lower casing;
    -- names with intentional mixed case ("BlueStar") are left alone
    case
        when clean_name in (upper(clean_name), lower(clean_name))
            then {{ title_case('clean_name') }}
        else clean_name
    end                                                 as payer_name,
    case lower(trim(payer_type))
        when 'commercial' then 'Commercial'
        when 'medicare'   then 'Medicare'
        when 'medicaid'   then 'Medicaid'
        when 'self-pay'   then 'Self-Pay'
    end                                                 as payer_type
from source
