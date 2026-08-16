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

    select *
    from {{ source('raw', 'raw_merchants') }}

)

{#
    here I use distinct to guard against any potential double records for merchant_id,
    although, at the time there are no duplicates. This can safely be done because of
    the grain of merchant_id, 1 row per id.

    I used lower() and trim() for segment because I noticed they tend to be all lower case
    and trim guards against accidental insertion of white spaces. Whether this is necessary
    would really depend on how the data is inputted into the system and if there is any 
    chance for some type of error to be introduced. The same is done defensively for country,
    except with upper().
#}

, renamed as (

    select
        distinct
        merchant_id,
        merchant_name,
        mcc,
        lower(trim(segment))                    as segment,
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