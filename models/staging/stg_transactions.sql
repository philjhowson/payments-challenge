-- Example staging model. It types and renames the raw transactions source.
-- It intentionally does NOT solve every data-quality issue for you — that's part
-- of the exercise. Extend this, add stg_wallets / stg_merchants, and decide how
-- to handle the things you find.

with source as (

    select * from {{ source('raw', 'raw_transactions') }}

),

renamed as (

    select
        transaction_id,
        wallet_id,
        merchant_id,
        cast(amount_cents as integer)      as amount_cents,
        amount_cents / 100.0               as amount_eur,
        currency,
        status,
        nullif(decline_reason, '')         as decline_reason,
        payment_method,
        cast(created_at as timestamp)      as created_at
    from source

)

select * from renamed

-- TODO (candidate): the raw grain is not clean. Decide how to guarantee one row
-- per transaction here, and back it up with a test in the schema file.
