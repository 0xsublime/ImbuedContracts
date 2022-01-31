#!/bin/bash

source .dapprc
echo $SETH_CHAIN

export ETH_FROM=0x34EeE73e731fB2A428444e2b2957C36A9b145017
export ETH_GAS_PRICE=200000000000 # 200 Gwei. Using EIP1559, we will still only pay base fee. Monitor network conditions when deploying.
export ETH_PRIO_FEE=2000000000 # 2 Gwei
export SETH_CHAIN=ethlive

let maxWhitelistId=99
let startId=101
let maxAllowedMintId=199
let whitelistPrice=$((5*10**18/100))
nftAddress=0x000001E1b2b5f9825f4d50bD4906aff2F298af4e

dapp create ImbuedMintV2 --verify -- $maxWhitelistId $startId $maxAllowedMintId $whitelistPrice $nftAddress
