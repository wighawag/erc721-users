import {expect} from './chai-setup';
import {ethers, deployments} from 'hardhat';

describe('Lease', function () {
  it('should work', async function () {
    await deployments.fixture(['Lease']);
    const usersContract = await ethers.getContract('Lease');
    expect(usersContract.address).to.be.a('string');
  });
});
