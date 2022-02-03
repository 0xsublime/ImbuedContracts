#!/bin/bash

source .dapprc

export ETH_FROM=0x0258acF616aD45f5A9390d0Ea39641468596675E
export ETH_GAS_PRICE=200000000000 # 200 Gwei. Using EIP1559, we will still only pay base fee. Monitor network conditions when deploying.
export ETH_PRIO_FEE=2000000000 # 2 Gwei
export ETH_RPC_URL=$TESTNET_RPC_URL

[[ $(seth chain) == rinkeby ]] || (echo Bad network $(seth chain) && exit 10)

source scripts/deploy.sh

