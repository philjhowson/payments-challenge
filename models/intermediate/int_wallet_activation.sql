with wallets as (

    select
        wallet_id,
        created_at,
        strftime(created_at, '%Y-%m') as signup_month,
        status
    from {{ ref('stg_wallets') }}

),

authorized_transactions as (

    select
        wallet_id,
        created_at as transaction_created_at
    from {{ ref('stg_transactions') }}
    where status = 'authorized'

)

select
    w.wallet_id,
    w.signup_month,
    w.status,

    case
        when count(t.wallet_id) > 0 then 1
        else 0
    end as activated_30d

from wallets w

left join authorized_transactions t
    on w.wallet_id = t.wallet_id
    and t.transaction_created_at >= w.created_at
    and t.transaction_created_at < w.created_at + interval '30 days'

group by
    w.wallet_id,
    w.signup_month,
    w.status