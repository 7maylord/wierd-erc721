pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract FixedERC721 is ERC721, Ownable, ReentrancyGuard {
    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) Ownable(msg.sender) {}

    // W4: Restrict minting to owner
    function mint(address to, uint256 tokenId) public onlyOwner nonReentrant {
        _safeMint(to, tokenId);
    }

    // W1, W2, W3: Use OpenZeppelin’s ERC721 for full interface, safe transfers, and proper events
    // W5: Ownership handled correctly by ERC721
    // W6: ReentrancyGuard prevents reentrancy
}