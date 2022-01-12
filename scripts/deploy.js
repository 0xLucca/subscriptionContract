const main = async () => {
  const subscriptionContractFactory = await hre.ethers.getContractFactory(
    "Subscription"
  );
  const subscriptionContract = await subscriptionContractFactory.deploy();
  await subscriptionContract.deployed();
  console.log("Contract deployed to:", subscriptionContract.address);
};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

runMain();
