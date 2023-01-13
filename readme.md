# ERC-5192 Reference Implementation

- Specification: [EIP-5192: Minimal Soulbound
  NFTs](https://eips.ethereum.org/EIPS/eip-5192)
- Community: [Chat on Telegram](https://t.me/eip4973)

ERC-5192 enables all degrees of permanently transferrable to permanently
non-transferrable ERC-721 tokens. Examples include: Soulbound tokens,
Account-bound tokens, non-transferrable tokens, lockable tokens.

ERC-5192 is in status final meaning it won't change again. If you want to learn
about how ERC-5192 was created, check out [PEEPanEIP #89: EIP-5192: Minimal
Soulbound NFTs with Tim Daubenschütz by the Ethereum Cat
Herders](https://www.youtube.com/watch?v=unFTcUjQE3o).

## Installation

```bash
forge install https://github.com/attestate/ERC5192
```

```bash
npm install erc5192
```

## Usage

ERC5192 is an abstract contract that can be used to implement custom business
logic. ERC5192 uses OpenZeppelin's ERC721 implementation, so we can use
`function safeMint` to start minting tokens.

Below is an example of a non-transferrable token:

```solidity
import {ERC5192} from "ERC5192/ERC5192.sol";

contract NTT is ERC5192 {
  constructor(string memory _name, string memory _symbol, bool _isLocked)
    ERC5192(_name, _symbol, _isLocked)
  {}
  function safeMint(address to, uint256 tokenId) external {
    _safeMint(to, tokenId);
  }
}
```

```solidity
contract UseNTT {
  function useNTT() public {
    string memory name = "Non-transferrable NFT";
    string memory symbol = "NTT";
    bool isLocked = true;

    NTT ntt = new NTT(name, symbol, isLocked);

    address minter = address(this);
    uint256 tokenId = 0;
    ntt.safeMint(minter, tokenId);

    ntt.transferFrom(minter, receiver, tokenId); // revert. token is locked.
  }
}
```

However, more dynamic use cases are possible where a token's transferrability
is only locked temporarily or based on specific conditions.

## License

See License file.
