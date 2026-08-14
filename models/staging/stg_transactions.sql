{# 
    Staging model materialzed as incremental to avoid reloading the
    entire dataset every time this pipeline is run. I have currently
    done this on created_at, with the assumption that backfilling is
    not necessary or a problem. If backfilling is normal or needed,
    another incremental strategy is required.
#}

{{ config(
    materialized='incremental',
    unique_key='transaction_id'
) }}

{#
    I generally like to select the specific columns from the source
    because it protects downstream processes in the event of a source
    schema change.
#}

with source as (

    select transaction_id,
        wallet_id,
        merchant_id,
        amount_cents,
        currency,
        status,
        decline_reason,
        payment_method,
        created_at
    from {{ source('raw', 'raw_transactions') }}

),

renamed as (

    select
        distinct
        transaction_id,
        wallet_id,
        merchant_id,
        cast(amount_cents as integer)           as amount_cents,
        amount_cents / 100.0                    as amount_eur,
        currency,
        status,
        nullif(decline_reason, '')              as decline_reason,
        payment_method,
        cast(created_at as timestamp)           as created_at
    from source

)

select *
from renamed

{% if is_incremental() %}

where transaction_timestamp >= (
    select max(transaction_timestamp)
    from {{ this }}
)

{% endif %}