// contracts/MyNFT.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';

contract Albums is ERC721 {

    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) { }

    function createNewAlbum(uint256[] memory collectionId) public virtual returns (uint256 albumId)
    {

    }

}