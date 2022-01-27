// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "openzeppelin-contracts/access/Ownable.sol";
import "./IImbuedNFT.sol";

contract ImbuedMintV2 is Ownable {
    IImbuedNFT constant public NFT = IImbuedNFT(0x000001E1b2b5f9825f4d50bD4906aff2F298af4e);

    uint16 public nextId = 101;
    uint16 public maxId = 199;
    uint256 whitelistPrice = 0.05 ether;

    // only owner

    function adminMintAmount(address recipient, uint8 amount) external onlyOwner() {
        require(amount + nextId <= maxId, "can't mint that many");
        uint256 nextCache = nextId;
        unchecked {
            for (uint256 i = 0; i < amount; i++) {
                NFT.mint(recipient, nextCache);
                nextCache++;
            }
        }
        nextId += amount;
    }

    function adminMintSpecific(address recipient, uint256 tokenId) external onlyOwner() {
        NFT.mint(recipient, tokenId);
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
}
