{# 
    Staging model materialzed as incremental to avoid reloading the
    entire dataset every time this pipeline is run. I have currently
    done this on created_at, with the assumption that backfilling is
    not necessary or a problem. If backfilling is normal or needed,
    another incremental strategy is required.
#}

{{ config(
    materialized='incremental',
    unique_key='merchant_id'
) }}

with source as (

    select 
        merchant_id,
        merchant_name,
        mcc,
        segment,
        country,
        onboarded_at
    from {{ source('raw', 'raw_merchants') }}

)

{#
    here I use distinct to guard against any potential double records for merchant_id,
    although, at the time there are no duplicates. This can safely be done because of
    the grain of merchant_id, 1 row per id.
#}

, renamed as (

    select
        distinct
        merchant_id,
        merchant_name,
        mcc,
        segment,
        upper(trim(country))                    as country,
        cast(onboarded_at as timestamp)         as onboarded_at
    from source

)

select *
from renamed

{% if is_incremental() %}

where onboarded_at >= (
    select max(onboarded_at)
    from {{ this }}
)

{% endif %}
