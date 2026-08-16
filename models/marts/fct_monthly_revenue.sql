with monthly_revenue as (

    select
        strftime(created_at, '%Y-%m') as month,
        segment,

        sum(case
            when status = 'authorized'
            then amount_eur
            else 0
        end) as authorized_eur,

        sum(case
            when status = 'refunded'
            then amount_eur
            else 0
        end) as refunded_eur,

        sum(case
            when status = 'reversed'
            then amount_eur
            else 0
        end) as reversed_eur

    from {{ ref('int_transactions') }}

    group by
        month,
        segment

)

select
    month,
    segment,
    round(authorized_eur, 2) as authorized_eur,
    round(refunded_eur, 2) as refunded_eur,
    round(reversed_eur, 2) as reversed_eur,

    round(
        authorized_eur
        - refunded_eur
        - reversed_eur,
        2
    ) as net_revenue_eur,

    round(
        (
            authorized_eur
            - refunded_eur
            - reversed_eur
        )
        - lag(
            authorized_eur
            - refunded_eur
            - reversed_eur
        ) over (
            partition by segment
            order by month
        ),
        2
    ) as mom_change_eur

from monthly_revenue

order by
    month,
    segment