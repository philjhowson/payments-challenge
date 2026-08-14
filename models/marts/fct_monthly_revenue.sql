with transactions as (

    select *
    from {{ ref('stg_transactions') }}

),

merchants as (

    select
        merchant_id,
        segment
    from {{ ref('stg_merchants') }}

),

transaction_revenue as (

    select
        strftime(created_at, '%Y-%m') as month,
        m.segment,
        t.status,
        t.amount_cents

    from transactions t

    left join merchants m
        on t.merchant_id = m.merchant_id

),

monthly_revenue as (

    select
        month,
        segment,

        sum(
            case
                when status = 'authorized' then amount_cents
                else 0
            end
        ) as authorized_cents,

        sum(
            case
                when status = 'refunded' then amount_cents
                else 0
            end
        ) as refunded_cents,

        sum(
            case
                when status = 'reversed' then amount_cents
                else 0
            end
        ) as reversed_cents

    from transaction_revenue

    group by
        month,
        segment

)

select
    month,
    segment,
    authorized_cents / 100.0 as authorized_eur,
    refunded_cents / 100.0 as refunded_eur,
    reversed_cents / 100.0 as reversed_eur,
    (authorized_cents - refunded_cents - reversed_cents) / 100.0
        as net_revenue_eur

from monthly_revenue
order by month