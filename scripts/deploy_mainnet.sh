#!/bin/bash

source .dapprc

export ETH_FROM=0x34EeE73e731fB2A428444e2b2957C36A9b145017
export ETH_GAS_PRICE=200000000000 # 200 Gwei. Using EIP1559, we will still only pay base fee. Monitor network conditions when deploying.
export ETH_PRIO_FEE=2000000000 # 2 Gwei
export ETH_RPC_URL=$MAINNET_RPC_URL

[[ $(seth chain) == ethlive ]] || (echo Bad network $(seth chain) && exit 10)

source deploy.sh

