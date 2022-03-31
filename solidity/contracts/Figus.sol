// contracts/MyNFT.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC1155/ERC1155.sol';

contract Figus is ERC1155 {
    event NewCollectionCreated(uint256 collectionId);

    uint256 private _nextCollectionId;

    // collectionId => amount of figuIds on the collection
    //   This mapping is filled by the createNewCollection method and can be used to identify which figuIds belong to each collection
    mapping(uint256 => uint256) public collectionIds;

    // figuId => available amount to be minted
    //   This mappin indicates how many instances can be still minted for a particular figuId
    mapping(uint256 => uint256) public availableFigus;

    constructor(string memory uri_) ERC1155(uri_) { }

    function createNewCollection(uint256[] memory figusAmounts) public virtual returns (uint256 collectionId, uint256[] memory figusIds) {
        // Checks
        require(figusAmounts.length > 0, 'Empty Amounts');

        // Effects
        collectionId = _nextCollectionId;
        collectionIds[collectionId] = figusAmounts.length;
        figusIds = new uint256[](figusAmounts.length);
        for (uint256 i; i < figusIds.length; i++) {
            figusIds[i] = collectionId + 1 + i;
            availableFigus[figusIds[i]] = figusAmounts[i];
        }

        _nextCollectionId += figusAmounts.length + 1;

        // Interactions
        emit NewCollectionCreated(collectionId);

        return (collectionId, figusIds);
    }

    function buyFigus(uint256[] memory figusIds, uint256[] memory figusAmounts) public {
        // Checks
        require(figusIds.length > 0, 'Empty Ids');
        require(figusIds.length == figusAmounts.length, 'Different Sizes');

        // Effects
        for (uint256 i; i < figusIds.length; i++) {
            require(availableFigus[figusIds[i]] >= figusAmounts[i], 'Not Enough');
            availableFigus[figusIds[i]] -= figusAmounts[i];
        }
        _mintBatch(msg.sender, figusIds, figusAmounts, '');

        // Interactions
    }
}
