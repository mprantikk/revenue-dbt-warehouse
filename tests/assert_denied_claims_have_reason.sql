-- Every denied claim needs a CARC code so it can be worked.
select claim_id
from {{ ref('fct_claims') }}
where claim_status = 'denied' and denial_code is null
