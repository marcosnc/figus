// contracts/MyNFT.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol';

contract Albums is ERC721, IERC1155Receiver {
  constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {}

  function createNewAlbum(uint256[] memory collectionId) public virtual returns (uint256 albumId) {
    // _mint(to, tokenId);
  }

  function onERC1155Received(
    address operator,
    address from,
    uint256 id,
    uint256 value,
    bytes calldata data
  ) external returns (bytes4) {}

  function onERC1155BatchReceived(
    address operator,
    address from,
    uint256[] calldata ids,
    uint256[] calldata values,
    bytes calldata data
  ) external returns (bytes4) {}
}
