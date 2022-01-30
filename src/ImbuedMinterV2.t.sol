// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "ds-test/test.sol";

import "./ImbuedMinterV2.sol";

import "openzeppelin-contracts/token/ERC721/utils/ERC721Holder.sol";

contract ImbuedMinterV2Test is DSTest {
    ImbuedMintV2 minter;
    IImbuedNFT NFT;

    User user;

    function setUp() public {
        minter = new ImbuedMintV2();
        NFT = minter.NFT();
        NFT.setMintContract(address(minter));
        user = new User(minter);
        payable(user).transfer(10 ether);
        minter.adminMintAmount(address(user), 5);
        minter.setMaxWhitelistId(105);
    }

    function test_accessNFT() public {
        IImbuedNFT nft = minter.NFT();
        string memory baseURI = nft.baseURI();
        uint256 balance = nft.balanceOf(address(1));
        emit log_string(baseURI);
        emit log_uint(balance);
    }

    function test_adminMinorMint() public {
        uint16 nextId = minter.nextId();
        uint8 amount = 3; // uint8(minter.maxId() - nextId);
        minter.adminMintAmount(address(1), amount);
        assertEq(NFT.balanceOf(address(1)), amount);
        assertEq(minter.nextId(), nextId + amount);
    }

    function test_adminMajorMint() public {
        minter.adminMintSpecific(address(2), 100);
        assertEq(NFT.ownerOf(100), address(2));
    }

    function test_mint5() public {
        uint16 nextId = minter.nextId();
        user.mint5();
        for (uint256 i = 0; i < 5; i++) {
            assertEq(address(user), NFT.ownerOf(nextId + i));
        }
    }

    // Not real tests.

    function test_gasCostMint() public {
        user.mint();
    }

    function test_gasCostMint5() public {
        user.mint5();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}

contract User is ERC721Holder {

    ImbuedMintV2 minter;
    constructor(ImbuedMintV2 _minter) {
        minter = _minter;
    }

    function mint() external {
        uint16[] memory ids = new uint16[](1);
        ids[0] = 101;
        mint(ids);
    }

    function mint5() external {
        uint16[] memory ids = new uint16[](5);
        ids[0] = 101;
        ids[1] = 102;
        ids[2] = 103;
        ids[3] = 104;
        ids[4] = 105;
        mint(ids);
    }

    function mint(uint16[] memory tokenIds) public {
        minter.mint{value: 0.05 ether * tokenIds.length}(tokenIds);
    }

    receive() external payable {}
}
