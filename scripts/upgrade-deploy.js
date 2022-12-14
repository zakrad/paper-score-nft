
const { ethers, upgrades } = require('hardhat');

async function main() {

  const paperScore = await ethers.getContractFactory("PaperScore");
  const paperscore = await upgrades.upgradeProxy('0xB413151355d11A8bBF906d08D36E533565Aa1b39', paperScore);

  await paperscore.deployed();

  console.log(
    `deployed to ${paperscore.address}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});


// localhost 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0
// goerli 0xB6c29716216ba37eaCB3c449fCCA97EFbAc37037 proxy admin 0x143576D5774153ad2B1142d766176A46DDD79090