// SPDX-License-Identifier: MIT
// An example of a consumer contract that directly pays for each request.

pragma solidity ^0.8.0;
import {console} from "../lib/forge-std/src/console.sol";
import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {VRFV2WrapperConsumerBase} from "../lib/chainlink/contracts/src/v0.8/vrf/VRFV2WrapperConsumerBase.sol";
import {LinkTokenInterface} from "../lib/chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";

/**
 * Request testnet LINK and ETH here: https://faucets.chain.link/
 * Find information on LINK Token Contracts and get the latest ETH and LINK faucets here: https://docs.chain.link/docs/link-token-contracts/
 */

contract ChainlinkLuckyDraw is VRFV2WrapperConsumerBase, Ownable {
    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(
        uint256 requestId,
        uint256[] randomWords,
        uint256 payment
    );

    struct RequestStatus {
        uint256 paid; // amount paid in link
        bool fulfilled; // whether the request has been successfully fulfilled
        uint256[] randomWords;
    }
    mapping(uint256 => RequestStatus)
        public s_requests; /* requestId --> requestStatus */

    // past requests Id.
    uint256[] public requestIds;
    uint256 public lastRequestId;

    // Depends on the number of requested values that you want sent to the
    // fulfillRandomWords() function. Test and adjust
    // this limit based on the network that you select, the size of the request,
    // and the processing of the callback request in the fulfillRandomWords()
    // function.
    uint32 public callbackGasLimit = 100000;

    // The default is 3, but you can set this higher.
    uint16 public requestConfirmations = 3;

    // For this example, retrieve 2 random values in one request.
    // Cannot exceed VRFV2Wrapper.getConfig().maxNumWords.
    uint32 public numWords = 2;

    // Address LINK - hardcoded for Sepolia
    // address linkAddress = 0x779877A7B0D9E8603169DdbD7836e478b4624789;

    // address WRAPPER - hardcoded for Sepolia
    // address wrapperAddress = 0xab18414CD93297B0d12ac29E63Ca20f515b3DB46;

    address public linkAddress;
    address public wrapperAddress;

    constructor(
        address _linkAddress,
        address _wrapperAddress
    ) VRFV2WrapperConsumerBase(_linkAddress, _wrapperAddress) {
        linkAddress = _linkAddress;
        wrapperAddress = _wrapperAddress;
    }

    // function requestRandomWords()
    //     external
    //     onlyOwner
    //     returns (uint256 requestId)
    // {
    //     requestId = requestRandomness(
    //         callbackGasLimit,
    //         requestConfirmations,
    //         numWords
    //     );
    //     s_requests[requestId] = RequestStatus({
    //         paid: VRF_V2_WRAPPER.calculateRequestPrice(callbackGasLimit),
    //         randomWords: new uint256[](0),
    //         fulfilled: false
    //     });
    //     requestIds.push(requestId);
    //     lastRequestId = requestId;
    //     emit RequestSent(requestId, numWords);
    //     return requestId;
    // }

    function requestRandomWords(
        uint32 _callbackGasLimit,
        uint16 _requestConfirmations,
        uint32 _numWords
    ) public onlyOwner returns (uint256 requestId) {
        requestId = requestRandomness(
            _callbackGasLimit,
            _requestConfirmations,
            _numWords
        );
        uint256 paid = VRF_V2_WRAPPER.calculateRequestPrice(_callbackGasLimit);
        uint256 balance = LINK.balanceOf(address(this));
        if (balance < paid) revert InsufficientFunds(balance, paid);
        s_requests[requestId] = RequestStatus({
            paid: paid,
            randomWords: new uint256[](0),
            fulfilled: false
        });
        requestIds.push(requestId);
        lastRequestId = requestId;
        emit RequestSent(requestId, _numWords, paid);
        return requestId;
    }

    error InsufficientFunds(uint256 balance, uint256 paid);
    event RequestSent(uint256 requestId, uint32 numWords, uint256 paid);

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        require(s_requests[_requestId].paid > 0, "request not found");
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;
        emit RequestFulfilled(
            _requestId,
            _randomWords,
            s_requests[_requestId].paid
        );
    }

    function getRequestStatus(
        uint256 _requestId
    )
        public
        view
        returns (uint256 paid, bool fulfilled, uint256[] memory randomWords)
    {
        require(s_requests[_requestId].paid > 0, "request not found");
        RequestStatus memory request = s_requests[_requestId];
        return (request.paid, request.fulfilled, request.randomWords);
    }

    function setNumOfWinners(uint256 _numOfWinners) external onlyOwner {
        numOfWinners = _numOfWinners;
    }

    function setCandidateAddresses(
        address[] memory _candidates
    ) external onlyOwner {
        candidates = _candidates;
    }

    uint256 public randomResult;
    uint256 public numOfWinners;
    address[] public candidates;
    // address[] public winners;

    mapping(uint256 => address[] winners) requestId_to_winners;

    function getHistoricalWinners(
        uint256 requestId
    ) public view returns (address[] memory winners) {
        return requestId_to_winners[requestId];
    }

    function getWinners() public returns (address[] memory winners) {
        (
            uint256 paid,
            bool fulfilled,
            uint256[] memory randomWords
        ) = getRequestStatus(lastRequestId);

        uint256 randomness = randomWords[1];

        // Select winners
        winners = new address[](numOfWinners);

        for (uint i = 0; i < numOfWinners; i++) {
            winners[i] = candidates[randomness % candidates.length];
            randomness = uint(keccak256(abi.encode(randomness)));
        }
        requestId_to_winners[lastRequestId] = winners;
        emit WinnersSelected(winners);
        return winners;
    }

    event WinnersSelected(address[] winners);

    /**
     * Allow withdraw of Link tokens from the contract
     */

    function withdrawLink() external onlyOwner {
        require(
            LINK.transfer(msg.sender, LINK.balanceOf(address(this))),
            "Unable to transfer"
        );
    }
}
