dapp build

let maxWhitelistId=99
let startId=101
let maxAllowedMintId=199
let whitelistPrice=$((5*10**18/100))
nftAddress=0x000001E1b2b5f9825f4d50bD4906aff2F298af4e

echo $ETH_FROM with $(seth balance $ETH_FROM) on $(seth chain)
dapp create ImbuedMintV2 $maxWhitelistId $startId $maxAllowedMintId $whitelistPrice $nftAddress