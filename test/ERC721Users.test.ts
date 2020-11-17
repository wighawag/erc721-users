import {expect} from './chai-setup';
import {ethers, deployments} from 'hardhat';

describe('ERC721Users', function () {
  it('should deploy', async function () {
    await deployments.fixture(['ERC721Users']);
    const usersContract = await ethers.getContract('ERC721Users');
    expect(usersContract.address).to.be.a('string');
  });
});
