// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "openzeppelin-contracts/access/Ownable.sol";
import "./IImbuedNFT.sol";

contract ImbuedMintV3 is Ownable {
    IImbuedNFT constant public NFT = 0x000001E1b2b5f9825f4d50bD4906aff2F298af4e;
    IERC721 constant public metaverseMiamiTicket = IERC721(0x9B6F8932A5F75cEc3f20f91EabFD1a4e6e572C0A);

    uint16 constant public lifeMaxId       = 299;
    uint16 constant public longingMaxId    = 399;
    uint16 constant public friendshipMaxId = 499;
    // Order relevant variables per edition so that they are packed together,
    // reduced sload and sstore gas costs.
    uint16 public lifeNextId = 201;
    uint224 public lifePrice = 0.05 ether;

    uint16 public longingNextId = 301;
    uint224 public longingPrice = 0.05 ether;

    uint16 public friendshipNextId = 401;
    uint224 public friendshipPrice = 0.05 ether;
    mapping (uint256 => bool) public miamiTicketId2claimed; // token ids that are claimed.

    constructor(IImbuedNFT nft) {
        NFT = nft;
    }

    function mint() external payable {
        _mint(msg.sender, amount);
    }

    // only owner

    /// (Admin only) Admin can mint without paying fee, because they are allowed to withdraw anyway.
    /// @param recipient what address should be sent the new token, must be an
    ///        EOA or contract able to receive ERC721s.
    /// @param amount the number of tokens to mint, starting with id `nextId()`.
    function adminMintAmount(address recipient, uint8 amount) external payable onlyOwner() {
        _mint(recipient, amount);
    }

    /// (Admin only) Can mint *any* token ID. Intended foremost for minting
    /// major versions for the artworks.
    /// @param recipient what address should be sent the new token, must be an
    ///        EOA or contract able to receive ERC721s.
    /// @param tokenId which id to mint, may not be a previously minted one.
    function adminMintSpecific(address recipient, uint256 tokenId) external payable onlyOwner() {
        NFT.mint(recipient, tokenId);
    }

    /// (Admin only) Withdraw the entire contract balance to the recipient address.
    /// @param recipient where to send the ether balance.
    function withdrawAll(address payable recipient) external payable onlyOwner() {
        recipient.call{value: address(this).balance}("");
    }

    /// (Admin only) self-destruct the minting contract.
    /// @param recipient where to send the ether balance.
    function kill(address payable recipient) external payable onlyOwner() {
        selfdestruct(recipient);
    }

    // internal

    // Reentrancy protection: not needed. The only variable that has not yet
    // been updated is nextId.  If you try to mint again using re-entrancy, the
    // mint itself will fail.
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