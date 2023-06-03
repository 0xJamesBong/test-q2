// pragma solidity ^0.8.0;

// import {VRFConsumerBase} from "../lib/chainlink/contracts/src/v0.8/vrf/VRFConsumerBase.sol";
// import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

// contract LuckyDraw is VRFConsumerBase, Ownable {
//     bytes32 internal keyHash;
//     uint256 internal fee;

//     uint256 public randomResult;
//     uint256 public numOfWinners;
//     address[] public candidates;
//     address[] public winners;

//     event WinnersSelected(address[] winners);

//     constructor(
//         address _vrfCoordinator,
//         address _link,
//         bytes32 _keyHash
//     ) VRFConsumerBase(_vrfCoordinator, _link) {
//         keyHash = _keyHash;
//         fee = 0.1 * 10 ** 18; // 0.1 LINK
//     }

//     function setNumOfWinners(uint256 _numOfWinners) external onlyOwner {
//         numOfWinners = _numOfWinners;
//     }

//     function setCandidateAddresses(
//         address[] memory _candidates
//     ) external onlyOwner {
//         candidates = _candidates;
//     }

//     function withdrawLink() external onlyOwner {
//         require(
//             LINK.transfer(msg.sender, LINK.balanceOf(address(this))),
//             "Unable to transfer"
//         );
//     }

//     function getRandomNumber() public onlyOwner returns (bytes32 requestId) {
//         require(
//             LINK.balanceOf(address(this)) >= fee,
//             "Not enough LINK - fill contract with faucet"
//         );
//         return requestRandomness(keyHash, fee);
//     }

//     function fulfillRandomness(
//         bytes32 requestId,
//         uint256 randomness
//     ) internal override {
//         randomResult = randomness;

//         // Select winners
//         winners = new address[](numOfWinners);
//         for (uint i = 0; i < numOfWinners; i++) {
//             winners[i] = candidates[randomness % candidates.length];
//             randomness = uint(keccak256(abi.encode(randomness)));
//         }

//         emit WinnersSelected(winners);
//     }
// }
