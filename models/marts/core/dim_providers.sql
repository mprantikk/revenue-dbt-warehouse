select provider_id, provider_name, specialty, city
from {{ ref('stg_providers') }}
