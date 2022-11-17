// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "ds-test/test.sol";

import "../ImbuedMintDeployer.sol";

contract ImbuedDeployerTest is DSTest {

    IImbuedNFT constant NFT = IImbuedNFT(0x000001E1b2b5f9825f4d50bD4906aff2F298af4e);

    function setUp() public {}

    function test_deploy() public {
        ImbuedMintDeployer deployer = new ImbuedMintDeployer();
        ImbuedMintV2 minter = deployer.minter();
        NFT.setMintContract(address(minter));

        assertEq(address(this), minter.owner());
        assertEq(NFT.mintContract(), address(minter));

        emit log_address(address(this));
    }

    function test_rawDeploy() public {
        uint16 maxWhitelistId = 99;
        uint16 startId = 101;
        uint16 maxAllowedMintId = 199;
        uint256 whitelistPrice = 0.05 ether;
        ImbuedMintV2 minter = new ImbuedMintV2(maxWhitelistId, startId, maxAllowedMintId, whitelistPrice, NFT);
        NFT.setMintContract(address(minter));

        assertEq(address(this), minter.owner());
        assertEq(NFT.mintContract(), address(minter));

        emit log_address(address(this));
    }

}
