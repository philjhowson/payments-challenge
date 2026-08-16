{# 
    Staging model materialzed as incremental to avoid reloading the
    entire dataset every time this pipeline is run. I have currently
    done this on created_at, with the assumption that backfilling is
    not necessary or a problem. If backfilling is normal or needed,
    another incremental strategy is required.
#}

{{ config(
    materialized='incremental',
    unique_key='wallet_id'
) }}

with source as (

    select *
    from {{ source('raw', 'raw_wallets') }}

)

{#
    here I use distinct to guard against any potential double records for wallet_id,
    although, at the time there are no duplicates. This can safely be done because of
    the grain of wallet_id, 1 row per id.
#}

, renamed as (

    select
        distinct
        wallet_id,
        member_id,
        upper(trim(country))                            as country,
        onboarding_method,
        marketing_channel,
        status,
        cast(created_at as timestamp)                   as created_at
    from source

)

select *
from renamed

{% if is_incremental() %}

where created_at >= (
    select max(created_at)
    from {{ this }}
)

{% endif %}

