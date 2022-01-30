// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "openzeppelin-contracts/access/Ownable.sol";
import "./IImbuedNFT.sol";

contract ImbuedMintV2 is Ownable {
    IImbuedNFT constant public NFT = IImbuedNFT(0x000001E1b2b5f9825f4d50bD4906aff2F298af4e);

    uint16 public maxWhiteListId = 99;
    uint16 public nextId = 101;
    uint16 public maxId = 199;
    uint256 public whitelistPrice = 0.05 ether;

    mapping (uint256 => bool) public tokenid2claimed; // token ids that are claimed.

    /// Whitelist only mint.
    function mint(uint16[] calldata tokenIds) external payable {
        uint8 amount = uint8(tokenIds.length);
        require(msg.value == amount * whitelistPrice, "wrong amount of ether sent");

        unchecked {
            for (uint256 i = 0; i < amount; i++) {
                uint256 id = tokenIds[i];
                require(id <= maxWhiteListId, "not a whitelisted token id");
                require(!tokenid2claimed[id], "token already used for claim");
                address tokenOwner = NFT.ownerOf(id);
                require(msg.sender == tokenOwner
                    || msg.sender == NFT.getApproved(id)
                    || NFT.isApprovedForAll(tokenOwner, msg.sender)
                    , "sender not allowed to manage token");
                tokenid2claimed[id] = true;
            }
        }
        _mint(msg.sender, amount);
    }

    // only owner

    /// Admin can mint without paying fee, because they are allowed to withdraw anyway.
    function adminMintAmount(address recipient, uint8 amount) external payable onlyOwner() {
        _mint(recipient, amount);
    }

    /// Can mint *any* token ID. Intended foremost for minting major versions for the artworks.
    function adminMintSpecific(address recipient, uint256 tokenId) external payable onlyOwner() {
        NFT.mint(recipient, tokenId);
    }

    function setMaxWhitelistId(uint16 newMaxWhitelistId) external payable onlyOwner() {
        maxWhiteListId = newMaxWhitelistId;
    }

    function setNextId(uint16 newNextId) external payable onlyOwner() {
        nextId = newNextId;
    }

    function setMaxId(uint16 newMaxId) external payable onlyOwner() {
        maxId = newMaxId;
    }
    
    function setWhitelistPrice(uint256 newPrice) external payable onlyOwner() {
        whitelistPrice = newPrice;
    }

    function kill() external payable onlyOwner() {
        selfdestruct(payable(msg.sender));
    }

    function withdrawAll(address payable recipient) external payable onlyOwner() {
        recipient.call{value: address(this).balance}("");
    }

    // internal

    // TODO: reentrancy vuln?
    // Don't think so, because the only variable that has not yet been updated is nextId.
    // If you try to mint again using re-entrancy, the mint itself will fail.
    function _mint(address recipient, uint8 amount) internal {
        uint256 nextCache = nextId;
        unchecked {
            uint256 newNext = nextCache + amount;
            require(newNext - 1 <= maxId, "can't mint that many");
            for (uint256 i = 0; i < amount; i++) {
                require((nextCache + i) % 100 != 0, "minting a major token");
                NFT.mint(recipient, nextCache + i); // reentrancy danger. Handled by fact that same ID can't be minted twice.
            }
            nextId = uint16(newNext);
        }
    }
}