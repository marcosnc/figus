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

    figusFactory = await ethers.getContractFactory(
        'solidity/contracts/Figus.sol:Figus'
    );
    figus = await figusFactory.deploy('https://figus.it/{id}.json');

    snapshotId = await evm.snapshot.take();
  });

  beforeEach(async () => {
    await evm.snapshot.revert(snapshotId);
  });

  it('should allow create a new album', async () => {
    const uri = await figus.callStatic.uri(1);
    expect(uri).to.equal('https://figus.it/{id}.json');

    const owner: string = await figus.signer.getAddress()

    // Create the first collection and check ids and available amounts are ok
    const collection0FigusAmounts = [10, 23, 15]
    const collection0ExpectedId = 0
    const collection0: ContractTransaction = await figus.createNewCollection(collection0FigusAmounts, {from: owner});
    await expect(collection0).to.emit(figus, 'NewCollectionCreated').withArgs(collection0ExpectedId);
    expect(await figus.collectionIds(collection0ExpectedId)).to.equal(collection0FigusAmounts.length)
    for(let i=0; i < collection0FigusAmounts.length; i++) {
        expect(await figus.availableFigus(collection0ExpectedId+1+i)).to.equal(collection0FigusAmounts[i])
    }

    // Create a new collection and check ids and available amounts are ok
    const collection1FigusAmounts = [21, 22, 23, 24]
    const collection1ExpectedId = collection0ExpectedId + collection0FigusAmounts.length + 1
    const collection1: ContractTransaction = await figus.createNewCollection(collection1FigusAmounts, {from: owner});
    await expect(collection1).to.emit(figus, 'NewCollectionCreated').withArgs(collection1ExpectedId);
    expect(await figus.collectionIds(collection1ExpectedId)).to.equal(collection1FigusAmounts.length)
    for(let i=0; i < collection1FigusAmounts.length; i++) {
        expect(await figus.availableFigus(collection1ExpectedId+1+i)).to.equal(collection1FigusAmounts[i])
    }

    // Retrieve all the collections and figus ids
    let collectionId = 0
    let figusInCollection
    while((figusInCollection = (await figus.collectionIds(collectionId)).toNumber()) > 0) {
        const firstFiguId = collectionId + 1
        const lastFiguId  = collectionId + figusInCollection
        console.log("--------------------------------------------------")
        console.log("Collection Id      : ", collectionId)
        console.log("Figus in Collection: ", figusInCollection)
        console.log("First Figus Id     : ", firstFiguId)
        console.log("Last  Figus Id     : ", lastFiguId)
        console.log("Available items for each figu:")
        for(let figuId = firstFiguId; figuId <= lastFiguId; figuId++) {
            const availableFigus = (await figus.availableFigus(figuId)).toNumber()
            console.log(`  Figu Id: ${figuId}, available items: ${availableFigus}`)
        }
        collectionId = lastFiguId + 1
    }
    console.log("--------------------------------------------------")

  });
});
