// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "openzeppelin-contracts/access/Ownable.sol";
import "./IImbuedNFT.sol";

contract ImbuedMintV2 is Ownable {
    IImbuedNFT constant public NFT = IImbuedNFT(0x000001E1b2b5f9825f4d50bD4906aff2F298af4e);

    uint16 maxWhiteListId = 99;
    uint16 public nextId = 101;
    uint16 public maxId = 199;
    uint256 whitelistPrice = 0.05 ether;

    /// TODO: Pick how to do this. This is a naive and gas-efficient way
    /// Whitelist only mint.
    /// To save gas we use naive whitelisting
    mapping (address => bool) address2claimed; // callers that have claimed.

    function mintA(uint8 amount) external payable {
        require(msg.value == amount * whitelistPrice, "wrong amount of ether sent");

        require(!address2claimed[msg.sender], "sender already claimed");
        uint256 bal = NFT.balanceOf(msg.sender);
        require(bal >= amount, "mint amount too large");


       address2claimed[msg.sender] = true;
        _mint(msg.sender, amount);
    }

    /// TODO: Pick how to do this. This is a more exact way.
    // TODO Ensure only tokens of lower than X can be used for whitelist
    /// Whitelist only mint.
    mapping (uint256 => bool) tokenid2claimed; // token ids that are claimed.

    function mintB(uint8 amount) external payable {
        require(msg.value == amount * whitelistPrice, "wrong amount of ether sent");

        uint256 claimed = 0;
        uint256 i = 0;
        while (claimed < amount) {
            uint256 id = NFT.tokenOfOwnerByIndex(msg.sender, i);
            unchecked { i++; }
            if (tokenid2claimed[id] || id > maxWhiteListId) {
                continue;
            }
            tokenid2claimed[id] = true;
            unchecked { claimed++; }
        }
        _mint(msg.sender, amount);
    }

    function mintC(uint16[] calldata tokenIds) external payable {
        uint8 amount = uint8(tokenIds.length);
        require(msg.value == amount * whitelistPrice, "wrong amount of ether sent");

        unchecked {
            for (uint256 i = 0; i < amount; i++) {
                uint256 id = tokenIds[i];
                require(msg.sender == NFT.ownerOf(id), "not allowed to mint for tokenId");
                require(id <= maxWhiteListId, "not a whitelisted token id");
                require(!tokenid2claimed[id], "token already used for claim");
                tokenid2claimed[id] = true;
            }
        }
        _mint(msg.sender, amount);
    }

    // only owner

    function adminMintAmount(address recipient, uint8 amount) external onlyOwner() {
        require(amount + nextId <= maxId, "can't mint that many");
        _mint(recipient, amount);
    }

    function adminMintSpecific(address recipient, uint256 tokenId) external onlyOwner() {
        NFT.mint(recipient, tokenId);
    }

    function setMaxWhitelistId(uint16 newMaxWhitelistId) external onlyOwner() {
        maxWhiteListId = newMaxWhitelistId;
    }

    function setNextId(uint16 newNextId) external onlyOwner() {
        nextId = newNextId;
    }

    function setMaxId(uint16 newMaxId) external onlyOwner() {
        maxId = newMaxId;
    }
    
    function setWhitelistPrice(uint256 newPrice) external onlyOwner() {
        whitelistPrice = newPrice;
    }

    function kill() external onlyOwner() {
        selfdestruct(payable(msg.sender));
    }

    function withdrawAll(address payable recipient) external onlyOwner() {
        recipient.call{value: address(this).balance}("");
    }

    // internal

    // TODO: reentrancy?
    function _mint(address recipient, uint8 amount) internal {
        uint256 nextCache = nextId;
        require(nextCache + amount <= maxId, "can't mint that many");
        unchecked {
            for (uint256 i = 0; i < amount; i++) {
                NFT.mint(recipient, nextCache); // reentrancy danger. Handled by fact that same ID can't be minted twice.
                nextCache++;
            }
        }
        nextId += amount;
    }
}