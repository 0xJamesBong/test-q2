// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {VRFCoordinatorV2Mock} from "../lib/chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {MockV3Aggregator} from "../lib/chainlink/contracts/src/v0.8/tests/MockV3Aggregator.sol";
// import {LinkToken} from "../lib/chainlink/contracts/src/v0.4/LinkToken.sol";
// import {LinkTokenInterface} from "../lib/chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import {MockLinkToken} from "../lib/chainlink/contracts/src/v0.8/mocks/MockLinkToken.sol";
import {VRFV2Wrapper} from "../lib/chainlink/contracts/src/v0.8/vrf/VRFV2Wrapper.sol";
import {ChainlinkLuckyDraw} from "../src/ChainlinkLuckyDraw.sol";

contract ChinalinkLuckyDrawTest is Test {
    VRFCoordinatorV2Mock vrfCoordinatorV2Mock;
    MockV3Aggregator mockV3Aggregator;
    MockLinkToken mockLinkToken;
    VRFV2Wrapper vRFV2Wrapper;
    ChainlinkLuckyDraw chainlinkLuckyDraw;

    function setUp() public {
        uint96 _BASEFEE = 100000000000000000;
        uint96 _GASPRICELINK = 1000000000;
        vrfCoordinatorV2Mock = new VRFCoordinatorV2Mock(
            _BASEFEE, // base fee
            _GASPRICELINK // gas price link
        );
        // (We are considering that 1 LINK = 0.003 native tokens).
        uint8 _DECIMALS = 18;
        int256 _INITIALANSWER = 3000000000000000;

        mockV3Aggregator = new MockV3Aggregator(_DECIMALS, _INITIALANSWER);
        mockLinkToken = new MockLinkToken();
        // Under DEPLOY, fill in _LINK with the LinkToken contract address, _LINKETHFEED with the MockV3Aggregator contract address, and _COORDINATOR with the VRFCoordinatorV2Mock contract address.
        vRFV2Wrapper = new VRFV2Wrapper(
            address(mockLinkToken),
            address(mockV3Aggregator),
            address(vrfCoordinatorV2Mock)
        );
        vRFV2Wrapper.setConfig(
            60000, // _wrapperGasOverhead
            52000, // _coordinatorGasOverhead
            10, // _wrapperPremiumPercentage
            0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc, // _keyHash
            10 // _maxNumWords
        );

        // // Fund the VRFv2Wrapper subscription.
        // fundSubscription to fund the VRFV2Wrapper subscription. In this example, you can set the _subid to 1 (which is your newly created subscription ID) and the _amount to 10000000000000000000 (10 LINK).
        vrfCoordinatorV2Mock.fundSubscription(1, 10000000000000000000);
        // Deploy your VRF consumer contract.
        chainlinkLuckyDraw = new ChainlinkLuckyDraw(
            address(mockLinkToken),
            address(vRFV2Wrapper)
        );
        // Fund your consumer contract with LINK tokens.
        mockLinkToken.transfer(
            address(chainlinkLuckyDraw),
            10000000000000000000
        );
        //  fill in _callbackGasLimit with 300000, _requestConfirmations with 3 and _numWords with 3.
        uint256 requestId = chainlinkLuckyDraw.requestRandomWords(300000, 3, 3);

        vrfCoordinatorV2Mock.fulfillRandomWords(
            requestId,
            address(vRFV2Wrapper)
        );
    }

    function test_request_randomWords() public {
        uint256 lastRequestId = chainlinkLuckyDraw.lastRequestId();
        (
            uint256 paid,
            bool fulfilled,
            uint256[] memory randomWords
        ) = chainlinkLuckyDraw.getRequestStatus(lastRequestId);

        console.log("paid:", paid, "fulfilled:", fulfilled);
        for (uint256 i = 0; i < randomWords.length; i++) {
            console.log("random word", i, randomWords[i]);
        }
    }

    function getCandidates() public returns (address[] memory) {
        address[] memory candidates = new address[](100);
        for (uint256 i = 0; i < 100; i++) {
            candidates[i] = address(uint160(i));
        }
        return candidates;
    }

    function test_get_winners() public {
        address[] memory candidates = getCandidates();
        chainlinkLuckyDraw.setCandidateAddresses(candidates);
        chainlinkLuckyDraw.setNumOfWinners(3);
        address[] memory winners = chainlinkLuckyDraw.getWinners();

        for (uint256 i = 0; i < winners.length; i++) {
            console.log("winners", i, winners[i]);
        }
    }
}

// https://docs.chain.link/vrf/v2/direct-funding/examples/test-locally#testing-logic
// Deploy the VRFCoordinatorV2Mock. This contract is a mock of the VRFCoordinatorV2 contract.
// Deploy the MockV3Aggregator contract.
// Deploy the LinkToken contract.
// Deploy the VRFV2Wrapper contract.
// Call the VRFV2Wrapper setConfig function to set wrapper specific parameters.
// Fund the VRFv2Wrapper subscription.
// Call the the VRFCoordinatorV2Mock addConsumer function to add the wrapper contract to your subscription.
// Deploy your VRF consumer contract.
// Fund your consumer contract with LINK tokens.
// Request random words from your consumer contract.
// Call the VRFCoordinatorV2Mock fulfillRandomWords function to fulfill your consumer contract request.
