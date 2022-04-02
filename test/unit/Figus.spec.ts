import chai, { expect } from 'chai';
import { MockContract, MockContractFactory, smock } from '@defi-wonderland/smock';
import { Figus, Figus__factory } from '@typechained';
import { evm } from '@utils';
import { BigNumber, ContractTransaction } from 'ethers';
import { ethers } from 'hardhat';

chai.use(smock.matchers);

describe('Figus', () => {
  //   let figus: MockContract<Figus>;
  //   let figusFactory: MockContractFactory<Figus__factory>;

  let figus: Figus;
  let figusFactory: Figus__factory;

  let snapshotId: string;

  before(async () => {
    // figusFactory = await smock.mock<Figus__factory>('Figus');
    // figus = await figusFactory.deploy('https://figus.it/{id}.json');

    figusFactory = await ethers.getContractFactory('solidity/contracts/Figus.sol:Figus');
    figus = await figusFactory.deploy('https://figus.it/{id}.json');

    snapshotId = await evm.snapshot.take();
  });

  beforeEach(async () => {
    await evm.snapshot.revert(snapshotId);
  });

  it('should allow create a new album', async () => {
    const uri = await figus.callStatic.uri(1);
    expect(uri).to.equal('https://figus.it/{id}.json');

    const owner: string = await figus.signer.getAddress();

    // Create the first collection and check ids and available amounts are ok
    createCollectionAndValidate(figus, owner, [10, 23, 15], 1, 1);

    // Create a new collection and check ids and available amounts are ok
    createCollectionAndValidate(figus, owner, [21, 22, 23, 24], 2, 4);

    // Retrieve all the collections and figus ids
    let collectionId = 1;
    let collectionInfo;
    while ((collectionInfo = await figus.collectionsInfo(collectionId)).collectionSize > 0) {
      const firstFiguId = collectionInfo.firstFiguId.toNumber();
      const figusInCollection = collectionInfo.collectionSize;
      const lastFiguId = firstFiguId + figusInCollection - 1;
      console.log('--------------------------------------------------');
      console.log('Collection Id      : ', collectionId);
      console.log('Figus in Collection: ', figusInCollection);
      console.log('First Figus Id     : ', firstFiguId);
      console.log('Last  Figus Id     : ', lastFiguId);
      console.log('Available items for each figu:');
      for (let figuId = firstFiguId; figuId <= lastFiguId; figuId++) {
        const availableFigus = (await figus.availableFigus(figuId)).toNumber();
        console.log(`  Figu Id: ${figuId}, available items: ${availableFigus}`);
      }
      collectionId = collectionId + 1;
    }
    console.log('--------------------------------------------------');
  });
});

async function createCollectionAndValidate(
  figus: Figus,
  owner: string,
  figusAmounts: number[],
  expectedCollectionId: number,
  expectedFirstFiguId: number
) {
  const collection: ContractTransaction = await figus.createNewCollection(figusAmounts, { from: owner });
  await expect(collection).to.emit(figus, 'NewCollectionCreated').withArgs(expectedCollectionId, expectedFirstFiguId);
  const collectionInfo = await figus.collectionsInfo(expectedCollectionId);
  expect(collectionInfo.firstFiguId).to.equal(expectedFirstFiguId);
  expect(collectionInfo.collectionSize).to.equal(figusAmounts.length);
  for (let i = 0; i < figusAmounts.length; i++) {
    expect(await figus.availableFigus(expectedFirstFiguId + i)).to.equal(figusAmounts[i]);
  }
}
