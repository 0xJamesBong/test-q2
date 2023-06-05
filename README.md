### Deployment to Sepolia Testnet

In your `.env` file, include the following api keys:

```

SEPOLIA_RPC_URL=YOUR_SEPOLIA_RPC_URL
ETHERSCAN_API_KEY=YOUR_ETHERSCAN_API_KEY
MNEMONIC=YOUR_MNEMONIC

```

Then run

```shell
source .env
```

Then run

```shell
forge script script/ChainlinkLuckDrawScript.s.sol:ChainlinkLuckDrawScript --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv
```

### Calling the getWinners() function

To call the `getWinners()` function and retrieve the winners of the lucky draw, follow these steps:

1. Ensure that you have deployed the `ChainlinkLuckyDraw` contract on the desired blockchain network.

2. Set the number of winners by calling the `setNumOfWinners()` function, passing the desired number of winners as an argument. For example, `chainlinkLuckyDraw.setNumOfWinners(3)`.

3. Set the candidate addresses by calling the `setCandidateAddresses()` function, passing an array of candidate addresses as an argument. For example, `chainlinkLuckyDraw.setCandidateAddresses(candidates)`.

4. Request random words by calling the `requestRandomWords()` function. This function sends a request to the Chainlink VRF coordinator to generate random words. Make sure to provide the necessary gas limit, request confirmations, and number of words parameters. For example:

```
chainlinkLuckyDraw.requestRandomWords(
    chainlinkLuckyDraw.callbackGasLimit(),
    chainlinkLuckyDraw.requestConfirmations(),
    chainlinkLuckyDraw.numWords()
);
```

Note: In a real blockchain deployment, you can modify the `requestRandomWords()` function to be directly embedded within the `getWinners()` function for convenience. However, in a testing environment, you need to manually fulfill the random words by calling `vrfCoordinatorV2Mock.fulfillRandomWords()`.

5. Retrieve the winners by calling the `getWinners()` function. Only the contract owner can call this function. For example:

```
address[] memory winners = chainlinkLuckyDraw.getWinners();
```

Note: If a non-owner tries to call `getWinners()`, it will revert with the error message "Ownable: caller is not the owner".

6. Access and utilize the `winners` array to perform any further operations or display the winners as needed. For example, you can iterate over the `winners` array and log the winners' addresses using `console.log()`.

Additionally, the `getHistoricalWinners()` function allows you to retrieve the winners for a specific past request. You can pass the `requestId` as an argument to this function to obtain the corresponding winners array. This function is relevant if you want to track and access winners from previous draw requests.

It's important to note that the instructions provided above assume you are working with a deployed instance of the `ChainlinkLuckyDraw` contract and have the necessary ownership and permissions to execute the functions.

### Task Fulfilment

The task was to deploy a new proper contract and perform various operations. Here is a summary of the tasks completed and the associated transaction links on the Sepolia network:

1. Withdrawal of Link from the old problematic contract:
   Transaction: [0xd04029e4d30821a967d90875d7ec0bbf97b143724ba6a82a968b22a91a24a0ea](https://sepolia.etherscan.io/tx/0xd04029e4d30821a967d90875d7ec0bbf97b143724ba6a82a968b22a91a24a0ea)

2. Funding the new proper contract:
   Transaction: [0xcf9ac04bd806b0ac3869a7439238176850d71d3540f9dc8cb66359ba80a40b62](https://sepolia.etherscan.io/tx/0xcf9ac04bd806b0ac3869a7439238176850d71d3540f9dc8cb66359ba80a40b62)

3. Setting 10 candidate addresses in the new proper contract:
   Transaction: [0x240ad348769aa3f62fe0a52611e22b925e784860ea47788180808468f2a2227f](https://sepolia.etherscan.io/tx/0x240ad348769aa3f62fe0a52611e22b925e784860ea47788180808468f2a2227f)

4. Setting the number of winners to be 3:
   Transaction: [0xe17167c7e14a628fa9bd034ebbe96d8c5b97c50444c6171563467d80953dbdcc](https://sepolia.etherscan.io/tx/0xe17167c7e14a628fa9bd034ebbe96d8c5b97c50444c6171563467d80953dbdcc)

5. Requesting random words with 300000 gas limit, 3 confirmations, and 3 num_words:
   Transaction: [0x76cfebe82f8f742eef1da2521181fb0464660cc610c69518ab642b08a43eb18f](https://sepolia.etherscan.io/tx/0x76cfebe82f8f742eef1da2521181fb0464660cc610c69518ab642b08a43eb18f)

6. Getting the winners by calling the `getWinners()` function:
   Transaction: [0x9eb18d85093ed33d0e32d16cc839b3e49572945a2ae6fbd654261f548e9649d6](https://sepolia.etherscan.io/tx/0x9eb18d85093ed33d0e32d16cc839b3e49572945a2ae6fbd654261f548e9649d6)

7. Getting historical winners with requestId 87192138318126074432043196219906284779840906160006385954717378675150701353188:
   Winners: [0x0000000000000000000000000000000000000004, 0x0000000000000000000000000000000000000005, 0x0000000000000000000000000000000000000008]
