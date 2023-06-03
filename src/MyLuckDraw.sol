// pragma solidity ^0.8.0;

// import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
// import {VRFV2WrapperConsumerBase} from "../lib/chainlink/contracts/src/v0.8/vrf/VRFV2WrapperConsumerBase.sol";

// contract MyLuckyDraw is VRFV2WrapperConsumerBase, Ownable {
//     bytes32 internal keyHash;
//     uint256 internal fee;

//     uint256 public randomResult;
//     uint256 public numOfWinners;
//     address[] public candidates;
//     address[] public winners;

//     event WinnersSelected(address[] winners);

//     constructor(
//         address _link,
//         address _vrfV2Wrapper
//     ) VRFV2WrapperConsumerBase(_link, _vrfV2Wrapper) {}

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

//     function selectWinner()
//         public
//         onlyOwner
//         returns (address[] memory winners)
//     {
//         emit WinnersSelected(winners);
//     }

//     function fulfillRandomWords(
//         uint256 _requestId,
//         uint256[] memory _randomWords
//     ) internal virtual;
// }
