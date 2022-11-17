// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "ds-test/test.sol";

import "../ImbuedMinterV3.sol";

import "openzeppelin-contracts/token/ERC721/utils/ERC721Holder.sol";
import "./Cheat.sol";

contract ImbuedMinterV3Test is DSTest {
    ImbuedMintV3 minter;
    IImbuedNFT constant NFT = IImbuedNFT(0x000001E1b2b5f9825f4d50bD4906aff2F298af4e);
    CheatCodes cheat = (new Cheater()).cheat();
    address controller = 0x34EeE73e731fB2A428444e2b2957C36A9b145017;

    User user;

    receive() external payable {
        emit log_string("received");
        emit log_uint(msg.value / 10e16);
    }

    function setUp() public {
        minter = new ImbuedMintV3();
        cheat.prank(controller);
        NFT.setMintContract(address(minter));
        user = new User(minter);
        payable(user).transfer(10 ether);
        minter.adminMintAmount(address(user), ImbuedMintV3.Edition.LIFE, 5);
    }

    function test_accessNFT() public {
        IImbuedNFT nft = minter.NFT();
        string memory baseURI = nft.baseURI();
        uint256 balance = nft.balanceOf(address(1));
        emit log_string(baseURI);
        emit log_uint(balance);
    }

    function test_adminMinorMint() public {
        (uint16 nextId,,) = minter.mintInfos(0);
        uint8 amount = 3; // uint8(minter.maxId() - nextId);
        minter.adminMintAmount(address(1), ImbuedMintV3.Edition.LIFE, amount);
        assertEq(NFT.balanceOf(address(1)), amount);
        uint16 oldNextId = nextId;
        (nextId,,) = minter.mintInfos(0);
        assertEq(nextId, oldNextId + amount);
    }

    function test_adminMajorMint() public {
        minter.adminMintSpecific(address(2), 100);
        assertEq(NFT.ownerOf(100), address(2));
    }

    function test_mint5() public {
        (uint16 nextId,,) = minter.mintInfos(0);
        user.mint5();
        for (uint256 i = 0; i < 5; i++) {
            assertEq(address(user), NFT.ownerOf(nextId + i));
        }
        uint256 balance = address(this).balance;
        minter.withdrawAll(payable(address(this)));
        assertEq(balance + (0.05 ether * 5), address(this).balance);
    }

    function testFail_mintExisting(uint8 id) public {
        id = id % 100;
        minter.adminMintSpecific(address(user), id);
    }

    function testFail_mintAgain(uint8 id) public {
        id = id % uint8(NFT.balanceOf(address(user)));
        uint16[] memory ids = new uint16[](1);
        ids[0] = uint16(NFT.tokenOfOwnerByIndex(address(user), id));
        user.mint(ids);
        user.mint(ids);
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

    ImbuedMintV3 minter;
    constructor(ImbuedMintV3 _minter) {
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
        minter.mint{value: 0.05 ether * tokenIds.length}(ImbuedMintV3.Edition.LIFE, uint8(tokenIds.length));
    }

    receive() external payable {}
}
