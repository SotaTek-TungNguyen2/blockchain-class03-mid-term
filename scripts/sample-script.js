// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const ERC20Token = await hre.ethers.getContractFactory("ERC20Token");
  const erc20Token = await ERC20Token.deploy("Tung Nguyen", "TNT");

  await erc20Token.deployed();
  const erc20Symbol = await erc20Token.symbol();
  console.log("ERC20Token deployed to:", erc20Symbol, erc20Token.address);

  const ERC721Token = await hre.ethers.getContractFactory("ERC721Token");
  const erc721Token = await ERC721Token.deploy("Tung", "TNFT");

  await erc721Token.deployed();
  const erc721Symbol = await erc721Token.symbol();
  console.log("ERC721Token deployed to:", erc721Symbol, erc721Token.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
