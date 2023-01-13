// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.13;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import {IERC5192} from "./IERC5192.sol";

abstract contract ERC5192 is ERC721 {
  bool private isLocked;

  error ErrLocked();
  error ErrNotFound();

  constructor(string memory _name, string memory _symbol, bool _isLocked)
    ERC721(_name, _symbol)
  {
    isLocked = _isLocked;
  }

  modifier checkLock() {
    revert ErrLocked();
    _;
  }

  function locked(uint256 tokenId) external view returns (bool) {
    if (!_exists(tokenId)) revert ErrNotFound();
    return isLocked;
  }

  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId,
    bytes memory data
  ) public override checkLock {
    safeTransferFrom(from, to, tokenId, data);
  }

  function safeTransferFrom(address from, address to, uint256 tokenId)
    public
    override
    checkLock
  {
    safeTransferFrom(from, to, tokenId);
  }

  function transferFrom(address from, address to, uint256 tokenId)
    public
    override
    checkLock
  {
    transferFrom(from, to, tokenId);
  }

  function approve(address approved, uint256 tokenId) public override checkLock {
    approve(approved, tokenId);
  }

  function setApprovalForAll(address operator, bool approved)
    public
    override
    checkLock
  {
    setApprovalForAll(operator, approved);
  }

  function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override
    returns (bool)
  {
    return interfaceId == type(IERC5192).interfaceId
      || super.supportsInterface(interfaceId);
  }
}
