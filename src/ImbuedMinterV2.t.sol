// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "ds-test/test.sol";

import "./ImbuedMinterV2.sol";

contract ImbuedMinterV2Test is DSTest {
    ImbuedMintV2 minter;
    IImbuedNFT NFT;

    function setUp() public {
        minter = new ImbuedMintV2();
        NFT = minter.NFT();
        NFT.setMintContract(address(minter));
    }

    function test_accessNFT() public {
        IImbuedNFT nft = minter.NFT();
        string memory baseURI = nft.baseURI();
        uint256 balance = nft.balanceOf(address(1));
        emit log_string(baseURI);
        emit log_uint(balance);
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
