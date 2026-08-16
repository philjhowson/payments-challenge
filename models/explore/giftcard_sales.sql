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
    strftime(t.created_at, '%Y-%m')                     as month,
    w.country,
    count(*) as transaction_count,
    count(distinct t.wallet_id)                         as unique_wallets,
    round(sum(t.amount_eur), 2)                         as authorized_eur,
    round(avg(t.amount_eur), 2)                         as avg_transaction_eur,
    round(
        count(*) * 1.0 / count(distinct t.wallet_id),
        2
    )                                                   as transactions_per_wallet

from {{ ref('stg_transactions') }} t

join merchants m
    on t.merchant_id = m.merchant_id

join wallets w
    on t.wallet_id = w.wallet_id

where lower(trim(t.status)) = 'authorized'
  and lower(trim(m.segment)) = 'giftcard'
  and t.created_at >= '2025-08-01'
  and t.created_at < '2025-11-01'

group by
    w.country, strftime(t.created_at, '%Y-%m')

order by
    strftime(t.created_at, '%Y-%m') asc, authorized_eur desc