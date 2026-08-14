with wallets as (

    select
        wallet_id,
        created_at,
        strftime(created_at, '%Y-%m') as signup_month

    from {{ ref('stg_wallets') }}

),

authorized_transactions as (

    select
        wallet_id,
        created_at as transaction_created_at

    from {{ ref('stg_transactions') }}

    where status = 'authorized'

),

wallet_activation as (

    select
        w.wallet_id,
        w.signup_month,

        case
            when count(t.wallet_id) > 0 then 1
            else 0
        end as activated

    from wallets w

    left join authorized_transactions t
        on w.wallet_id = t.wallet_id
        and t.transaction_created_at >= w.created_at
        and t.transaction_created_at < w.created_at + interval '30 days'

    group by
        w.wallet_id,
        w.signup_month

)

select
    signup_month,
    count(*) as wallet_count,
    sum(activated) as activated_wallets,
    sum(activated) * 1.0 / count(*) as activation_rate

from wallet_activation

group by signup_month
order by signup_month