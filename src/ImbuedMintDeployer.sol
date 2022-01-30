// SPDX-License-Identifier: GPL-3.0-or-later

import "./ImbuedMinterV2.sol";

contract ImbuedMintDeployer {

    IImbuedNFT constant NFT = IImbuedNFT(0x000001E1b2b5f9825f4d50bD4906aff2F298af4e);
    ImbuedMintV2 public minter;
    constructor() {
        uint16 maxWhitelistId = 99;
        uint16 startId = 101;
        uint16 maxAllowedMintId = 199;
        uint256 whitelistPrice = 0.05 ether;
        minter = new ImbuedMintV2(maxWhitelistId, startId, maxAllowedMintId, whitelistPrice, NFT);
        minter.transferOwnership(msg.sender);
    }

    function kill() external {
        selfdestruct(payable(msg.sender));
    }
}