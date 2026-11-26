with source as (
    select * from {{ ref('raw_providers') }}
)

select
    provider_id,
    {{ title_case('trim(provider_name)') }}   as provider_name,   -- "DR. PROVIDER 05 " -> "Dr. Provider 05"
    specialty,
    city
from source
