// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {ERC721Holder} from
  "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

import {ERC5192} from "../src/ERC5192.sol";
import {IERC5192} from "../src/IERC5192.sol";

contract NTT is ERC5192 {
  constructor(string memory _name, string memory _symbol, bool _isLocked)
    ERC5192(_name, _symbol, _isLocked)
  {}

  function safeMint(address to, uint256 tokenId) external {
    _safeMint(to, tokenId);
  }
}

contract ERC5192Test is Test, ERC721Holder {
  NTT lockedToken;
  NTT unlockedToken;

  function setUp() public {
    string memory name = "Name";
    string memory symbol = "Symbol";
    lockedToken = new NTT(name, symbol, true);
    unlockedToken = new NTT(name, symbol, false);
  }

  function testCallingLockedOnUnlocked() public {
    address to = address(this);
    uint256 tokenId = 0;
    unlockedToken.safeMint(to, tokenId);
    assertFalse(unlockedToken.locked(tokenId));
  }

  function testCallingLockedOnLocked() public {
    address to = address(this);
    uint256 tokenId = 0;
    lockedToken.safeMint(to, tokenId);
    assertTrue(lockedToken.locked(tokenId));
  }

  function testIERC5192() public {
    assertTrue(lockedToken.supportsInterface(type(IERC5192).interfaceId));
    assertTrue(unlockedToken.supportsInterface(type(IERC5192).interfaceId));
  }

  function testLockedThrowingOnNonExistentTokenId() public {
    vm.expectRevert(ERC5192.ErrNotFound.selector);
    lockedToken.locked(1337);

    vm.expectRevert(ERC5192.ErrNotFound.selector);
    unlockedToken.locked(1337);
  }

  function testEnabledSafeTransferFromWithData() public {
    address to = address(this);
    uint256 tokenId = 0;
    unlockedToken.safeMint(to, tokenId);

    bytes memory data;
    address receiver = address(1);
    unlockedToken.safeTransferFrom(address(this), receiver, tokenId, data);
    assertEq(unlockedToken.ownerOf(tokenId), receiver);
  }

  function testEnabledSafeTransferFrom() public {
    address to = address(this);
    uint256 tokenId = 0;
    unlockedToken.safeMint(to, tokenId);

    address receiver = address(1);
    unlockedToken.safeTransferFrom(address(this), receiver, tokenId);
    assertEq(unlockedToken.ownerOf(tokenId), receiver);
  }

  function testBlockedSafeTransferFrom() public {
    address to = address(this);
    uint256 tokenId = 0;
    lockedToken.safeMint(to, tokenId);

    bytes memory data;
    vm.expectRevert(ERC5192.ErrLocked.selector);
    lockedToken.safeTransferFrom(address(this), address(1), tokenId, data);

    vm.expectRevert(ERC5192.ErrLocked.selector);
    lockedToken.safeTransferFrom(address(this), address(1), tokenId);
  }

  function testEnabledTransferFrom() public {
    address to = address(this);
    uint256 tokenId = 0;
    unlockedToken.safeMint(to, tokenId);

    address receiver = address(1);
    unlockedToken.transferFrom(address(this), receiver, tokenId);
    assertEq(unlockedToken.ownerOf(tokenId), receiver);
  }

  function testBlockedTransferFrom() public {
    address to = address(this);
    uint256 tokenId = 0;
    lockedToken.safeMint(to, tokenId);

    vm.expectRevert(ERC5192.ErrLocked.selector);
    lockedToken.transferFrom(address(this), address(1), tokenId);
  }

  function testEnabledApprove() public {
    address to = address(this);
    uint256 tokenId = 0;
    unlockedToken.safeMint(to, tokenId);

    address receiver = address(1);
    unlockedToken.approve(receiver, tokenId);
    assertEq(unlockedToken.getApproved(tokenId), receiver);
  }

  function testBlockedApprove() public {
    address to = address(this);
    uint256 tokenId = 0;
    lockedToken.safeMint(to, tokenId);

    vm.expectRevert(ERC5192.ErrLocked.selector);
    lockedToken.approve(address(1), tokenId);
  }

  function testEnabledSetApproveForAll() public {
    address to = address(this);
    uint256 tokenId = 0;
    unlockedToken.safeMint(to, tokenId);

    address operator = address(1);
    unlockedToken.setApprovalForAll(operator, true);
    assertEq(unlockedToken.isApprovedForAll(to, operator), true);
  }

  function testBlockedSetApprovalForAll() public {
    vm.expectRevert(ERC5192.ErrLocked.selector);
    lockedToken.setApprovalForAll(address(1), true);
  }
}
