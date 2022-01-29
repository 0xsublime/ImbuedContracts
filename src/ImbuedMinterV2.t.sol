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
        user = new User();
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

    function test_gasCostMintA() public {
        user.mintA(minter);
    }

    function test_gasCostMintB() public {
        user.mintB(minter);
    }

    function test_gasCostMintC() public {
        user.mintC(minter);
    }

    function test_gasCostMintA5() public {
        user.mintA5(minter);
    }

    function test_gasCostMintB5() public {
        user.mintB5(minter);
    }

    function test_gasCostMintC5() public {
        user.mintC5(minter);
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}

contract User is ERC721Holder {

    function mintA(ImbuedMintV2 minter) external {
        minter.mintA{value: 0.05 ether * 1}(1);
    }

    function mintB(ImbuedMintV2 minter) external {
        minter.mintB{value: 0.05 ether * 1}(1);
    }

    function mintC(ImbuedMintV2 minter) external {
        uint16[] memory ids = new uint16[](1);
        ids[0] = 101;
        minter.mintC{value: 0.05 ether * 1}(ids);
    }

    function mintA5(ImbuedMintV2 minter) external {
        minter.mintA{value: 0.05 ether * 5}(5);
    }

    function mintB5(ImbuedMintV2 minter) external {
        minter.mintB{value: 0.05 ether * 5}(5);
    }

    function mintC5(ImbuedMintV2 minter) external {
        uint16[] memory ids = new uint16[](5);
        ids[0] = 101;
        ids[1] = 102;
        ids[2] = 103;
        ids[3] = 104;
        ids[4] = 105;
        minter.mintC{value: 0.05 ether * 5}(ids);
    }

    receive() external payable {}
}
