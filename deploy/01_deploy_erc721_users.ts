import {BuidlerRuntimeEnvironment, DeployFunction} from '@nomiclabs/buidler/types';

const func: DeployFunction = async function (bre: BuidlerRuntimeEnvironment) {
  const {deployer} = await bre.getNamedAccounts();
  const {deploy} = bre.deployments;
  await deploy('ERC721Users', {from: deployer, log: true});
};
export default func;
