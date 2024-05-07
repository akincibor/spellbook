{{ config(
    schema = 'opensea_v4_avalanche_c',
    alias = 'events',
    materialized = 'incremental',
    file_format = 'delta',
    incremental_strategy = 'merge',
    unique_key = ['tx_hash', 'evt_index', 'nft_contract_address', 'token_id', 'sub_type', 'sub_idx']
    )
}}

WITH fee_wallets as (
    select wallet_address, wallet_name from (
    values (0x0000a26b00c1f0df003000390027140000faa719,'opensea')
    ) as foo(wallet_address, wallet_name)
)
, trades as (
    {{ seaport_v4_trades(
     blockchain = 'avalanche_c'
     ,source_transactions = source('avalanche_c','transactions')
     ,Seaport_evt_OrderFulfilled = source('seaport_avalanche_c','Seaport_evt_OrderFulfilled')
     ,Seaport_evt_OrdersMatched = source('seaport_avalanche_c','Seaport_evt_OrdersMatched')
     ,fee_wallet_list_cte = 'fee_wallets'
     ,start_date = '2023-02-01'
     ,native_currency_contract = '0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7'
    )
  }}
)

select *
from trades
where (    fee_wallet_name = 'opensea'
           or right_hash = 0x360c6ebe
         )