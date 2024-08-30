{{ config(
    schema = 'dex_ethereum'
    , alias = 'mass_decoded_trades'
    , materialized = 'view'
    )
}}

{% set base_models = [
    
      ref('uniswap_v2_forks_base_trades_ethereum')
    , ref('uniswap_v3_forks_base_trades_ethereum')
] %}

WITH base_union AS (
    SELECT *
    FROM (
        {% for base_model in base_models %}
        SELECT
            blockchain
            , project
            , version
            , dex_type
            , factory_address
            , block_month
            , block_date
            , block_time
            , block_number
            , token_bought_amount_raw
            , token_sold_amount_raw
            , token_bought_address
            , token_sold_address
            , taker
            , maker
            , project_contract_address
            , tx_hash
            , evt_index
            , factory_address
        FROM
            {{ base_model }}
        {% if not loop.last %}
        UNION ALL
        {% endif %}
        {% endfor %}
    )
)

{{
    add_tx_columns(
        model_cte = 'base_union'
        , blockchain = 'ethereum'
        , columns = ['from', 'to', 'index']
    )
}}
