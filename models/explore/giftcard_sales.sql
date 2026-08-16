{#
    Exploratory model used to investigate the September gift-card revenue
    anomaly by country. The aggregation could be promoted to a reusable fact
    table if country-level segment performance becomes a recurring business
    requirement.
#}

select
    strftime(created_at, '%Y-%m') as month,
    country,
    count(*) as transaction_count,
    count(distinct wallet_id) as unique_wallets,
    round(sum(amount_eur), 2) as authorized_eur,
    round(avg(amount_eur), 2) as avg_transaction_eur,
    round(
        count(*) * 1.0 / count(distinct wallet_id),
        2
    ) as transactions_per_wallet

from {{ ref('int_transactions') }}

where status = 'authorized'
  and segment = 'giftcard'
  and created_at >= '2025-08-01'
  and created_at < '2025-11-01'

group by
    country,
    strftime(created_at, '%Y-%m')

order by
    month asc,
    authorized_eur desc