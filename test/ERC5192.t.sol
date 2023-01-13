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

  function setUp() public {
    string memory name = "Name";
    string memory symbol = "Symbol";
    bool locked = true;
    lockedToken = new NTT(name, symbol, locked);
  }

  function testCallingLocked() public {
    address to = address(this);
    uint256 tokenId = 0;
    lockedToken.safeMint(to, tokenId);
    assertTrue(lockedToken.locked(tokenId));
  }

  function testIERC5192() public {
    assertTrue(lockedToken.supportsInterface(type(IERC5192).interfaceId));
  }

  function testLockedThrowingOnNonExistentTokenId() public {
    vm.expectRevert(ERC5192.ErrNotFound.selector);
    lockedToken.locked(1337);
  }

  function testBlockedSafeTransferFrom() public {
    address from = address(0);
    address to = address(this);
    uint256 tokenId = 0;
    lockedToken.safeMint(to, tokenId);

    bytes memory data;
    vm.expectRevert(ERC5192.ErrLocked.selector);
    lockedToken.safeTransferFrom(address(this), address(1), tokenId, data);

    vm.expectRevert(ERC5192.ErrLocked.selector);
    lockedToken.safeTransferFrom(address(this), address(1), tokenId);
  }

  function testBlockedTransferFrom() public {
    address from = address(0);
    address to = address(this);
    uint256 tokenId = 0;
    lockedToken.safeMint(to, tokenId);

    vm.expectRevert(ERC5192.ErrLocked.selector);
    lockedToken.transferFrom(address(this), address(1), tokenId);
  }

  function testBlockedApprove() public {
    address from = address(0);
    address to = address(this);
    uint256 tokenId = 0;
    lockedToken.safeMint(to, tokenId);

    vm.expectRevert(ERC5192.ErrLocked.selector);
    lockedToken.approve(address(1), tokenId);
  }

  function testBlockedSetApprovalForAll() public {
    vm.expectRevert(ERC5192.ErrLocked.selector);
    lockedToken.setApprovalForAll(address(1), true);
  }
}
