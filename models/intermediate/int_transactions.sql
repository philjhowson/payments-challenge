with merchants as (

    select
        merchant_id,
        segment
    from {{ ref('stg_merchants') }}

),

wallets as (

    select
        wallet_id,
        country
    from {{ ref('stg_wallets') }}

)

select
    t.transaction_id,
    t.wallet_id,
    t.merchant_id,
    t.created_at,
    t.amount_eur,
    t.status,
    m.segment,
    w.country

from {{ ref('stg_transactions') }} t

left join merchants m
    on t.merchant_id = m.merchant_id

left join wallets w
    on t.wallet_id = w.wallet_id