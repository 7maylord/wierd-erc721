pragma solidity ^0.8.0;

contract BuggyERC721 {
    mapping(uint256 => address) public ownerOf;
    mapping(address => uint256) public balanceOf;
    mapping(uint256 => address) public getApproved;
    mapping(address => mapping(address => bool)) public isApprovedForAll;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    // W3: No Approval event

    // this is a test git comment

    // W4: Anyone can mint
    function mint(address to, uint256 tokenId) public {
        ownerOf[tokenId] = to;
        balanceOf[to]++;
        emit Transfer(address(0), to, tokenId);
    }

    // W1: Incomplete interface (missing safeTransferFrom)
    // W2: Unsafe transfer
    function transferFrom(address from, address to, uint256 tokenId) public {
        require(ownerOf[tokenId] == from, "Not owner");
        ownerOf[tokenId] = to;
        balanceOf[from]--;
        balanceOf[to]++;
        // W3: Incorrect event (no approval clearing)
        emit Transfer(from, to, tokenId);
    }

    // W3: No Approval event
    function approve(address to, uint256 tokenId) public {
        getApproved[tokenId] = to;
    }

    // W5: Ownership can be overwritten
    // (mint allows overwriting existing token IDs)

    // W6: Reentrancy risk
    function transferFrom(address from, address to, uint256 tokenId) public {
        // Same as above, no reentrancy protection
    }
}