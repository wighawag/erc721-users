import {expect} from './chai-setup';
import {ethers, deployments} from '@nomiclabs/buidler';

describe('ERC721Users', function () {
  it('should work', async function () {
    await deployments.fixture();
    const usersContract = await ethers.getContract('ERC721Users');
    expect(usersContract.address).to.be.a('string');
  });
});
