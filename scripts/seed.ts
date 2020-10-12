import {getUnnamedAccounts} from '@nomiclabs/buidler';

async function main() {
  const others = await getUnnamedAccounts();
  console.log({others});
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
