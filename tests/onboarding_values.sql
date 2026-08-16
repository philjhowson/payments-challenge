select *
from {{ ref('stg_wallets') }}
where onboarding_method not in ('sdd', 'card')