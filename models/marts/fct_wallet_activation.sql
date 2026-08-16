with wallet_activation as (

    select *
    from {{ ref('int_wallet_activation') }}

)

select
    signup_month,

    count(*) as wallet_count,

    sum(activated_30d) as activated_wallets,

    round(
        sum(activated_30d) * 1.0 / count(*),
        2
    ) as activation_rate,

    round(
        (sum(activated_30d) * 1.0 / count(*))
        - lag(sum(activated_30d) * 1.0 / count(*))
            over (order by signup_month),
        2
    ) as mom_change,

    sum(case when status = 'active' then 1 else 0 end)
        as active_wallets,

    round(
        sum(case when status = 'active' then 1 else 0 end) * 1.0
        / count(*),
        2
    ) as active_rate,

    sum(case when status = 'blocked' then 1 else 0 end)
        as blocked_wallets,

    round(
        sum(case when status = 'blocked' then 1 else 0 end) * 1.0
        / count(*),
        2
    ) as blocked_rate,

    sum(case when status = 'churned' then 1 else 0 end)
        as churned_wallets,

    round(
        sum(case when status = 'churned' then 1 else 0 end) * 1.0
        / count(*),
        2
    ) as churned_rate

from wallet_activation

group by signup_month

order by signup_month