select *
from {{ ref('stg_transactions') }}
where amount_cents <= 0