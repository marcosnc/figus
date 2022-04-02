// contracts/MyNFT.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC1155/ERC1155.sol';

contract Figus is ERC1155 {
  event NewCollectionCreated(uint256 collectionId, uint256 firstFiguId);

  uint256 private _nextCollectionId;
  uint256 private _nextFiguId;

  struct CollectionInfo {
    uint240 firstFiguId; // 30 Bytes // Slot 1
    uint16 collectionSize; //  2 Bytes // Slot 1
  }

  // collectionId => CollectionInfo
  //   This mapping is filled by the createNewCollection method and can be used to identify which figuIds belong to each collection
  mapping(uint256 => CollectionInfo) public collectionsInfo;

  // figuId => available amount to be minted
  //   This mapping indicates how many instances can be still minted for a particular figuId
  mapping(uint256 => uint256) public availableFigus;

  constructor(string memory uri_) ERC1155(uri_) {}

  function createNewCollection(uint256[] memory figusAmounts) public virtual returns (uint256 collectionId, uint256[] memory figusIds) {
    // Checks
    require(figusAmounts.length > 0, 'Empty Amounts');

    // Effects
    collectionId = ++_nextCollectionId;
    collectionsInfo[collectionId] = CollectionInfo({firstFiguId: uint240(_nextFiguId + 1), collectionSize: uint16(figusAmounts.length)});
    figusIds = new uint256[](figusAmounts.length);
    for (uint256 i; i < figusIds.length; i++) {
      figusIds[i] = ++_nextFiguId;
      availableFigus[figusIds[i]] = figusAmounts[i];
    }

    // Interactions
    emit NewCollectionCreated(collectionId, collectionsInfo[collectionId].firstFiguId);

    return (collectionId, figusIds);
  }

  function buyFigus(uint256[] memory figusIds, uint256[] memory figusAmounts) public {
    // Checks
    require(figusIds.length > 0, 'Empty Ids');
    require(figusIds.length == figusAmounts.length, 'Different Sizes');

    // Effects
    for (uint256 i; i < figusIds.length; i++) {
      availableFigus[figusIds[i]] -= figusAmounts[i]; // Assuming an error is raised if availableFigus[figusIds[i]] < 0
    }
    _mintBatch(msg.sender, figusIds, figusAmounts, '');

    // Interactions
  }
}
