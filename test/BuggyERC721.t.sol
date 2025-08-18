// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import "../BuggyERC721.sol";
import "../FixedERC721.sol";

contract BuggyERC721Test is Test {
    BuggyERC721 public buggy;
    FixedERC721 public fixed;
    address public owner = address(this);
    address public addr1 = address(0x1);
    address public addr2 = address(0x2);

    function setUp() public {
        buggy = new BuggyERC721();
        fixed = new FixedERC721("Fixed NFT", "FNFT");
    }

    // W1: BuggyERC721 lacks safeTransferFrom (verified by code inspection)
    // W2: BuggyERC721 unsafe transfer
    function testW2UnsafeTransfer() public {
        buggy.mint(addr1, 1);
        vm.prank(addr1);
        buggy.transferFrom(addr1, addr2, 1);
        assertEq(buggy.ownerOf(1), addr2);
    }

    // W3: BuggyERC721 lacks Approval event
    function testW3NoApprovalEvent() public {
        buggy.mint(addr1, 1);
        vm.prank(addr1);
        vm.expectEmit(false, false, false, false);
        emit Approval(addr1, addr2, 1);
        buggy.approve(addr2, 1);
    }

    // W4: BuggyERC721 allows anyone to mint
    function testW4AnyoneCanMintBuggy() public {
        vm.prank(addr1);
        buggy.mint(addr1, 1);
        assertEq(buggy.ownerOf(1), addr1);
    }

    // W4: FixedERC721 restricts minting to owner
    function testW4OnlyOwnerCanMintFixed() public {
        vm.prank(addr1);
        vm.expectRevert("Ownable: caller is not the owner");
        fixed.mint(addr1, 1);

        vm.prank(owner);
        fixed.mint(addr1, 1);
        assertEq(fixed.ownerOf(1), addr1);
    }

    // W5: BuggyERC721 allows ownership overwrite
    function testW5OwnershipOverwrite() public {
        buggy.mint(addr1, 1);
        buggy.mint(addr2, 1); // Overwrites
        assertEq(buggy.ownerOf(1), addr2);
    }

    // W6: BuggyERC721 reentrancy risk (tested with malicious contract)
    function testW6ReentrancyRisk() public {
        MaliciousContract malicious = new MaliciousContract(address(buggy));
        buggy.mint(address(malicious), 1);
        vm.prank(address(malicious));
        buggy.transferFrom(address(malicious), addr2, 1);
        // Reentrancy allows multiple transfers, verified by code inspection
    }
}

contract MaliciousContract {
    BuggyERC721 public buggy;
    bool public attacked;

    constructor(address _buggy) {
        buggy = BuggyERC721(_buggy);
    }

    function onERC721Received(address, address, uint256, bytes memory) public returns (bytes4) {
        if (!attacked) {
            attacked = true;
            buggy.transferFrom(address(this), address(0x2), 1);
        }
        return this.onERC721Received.selector;
    }
}

event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);