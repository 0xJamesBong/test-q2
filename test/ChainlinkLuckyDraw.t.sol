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
    address alice = address(0xAA); // alice is designated the owner of the pizza contract
    address bob = address(0xBB);
    address carol = address(0xCC);
    address dominic = address(0xDD);

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
        // //  fill in _callbackGasLimit with 300000, _requestConfirmations with 3 and _numWords with 3.
        // uint256 requestId = chainlinkLuckyDraw.requestRandomWords(300000, 3, 3);

        // vrfCoordinatorV2Mock.fulfillRandomWords(
        //     requestId,
        //     address(vRFV2Wrapper)
        // );
    }

    function test_owner() public {
        assertEq(chainlinkLuckyDraw.owner(), address(this));
    }

    function test_request_randomWords() public {
        uint256 requestId = chainlinkLuckyDraw.requestRandomWords(300000, 3, 3);
        uint256 lastRequestId = chainlinkLuckyDraw.lastRequestId();
        vrfCoordinatorV2Mock.fulfillRandomWords(
            lastRequestId,
            address(vRFV2Wrapper)
        );
        assertEq(requestId, lastRequestId);
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

    function test_set_candidates() public {
        address[] memory candidates = getCandidates();
        chainlinkLuckyDraw.setCandidateAddresses(candidates);
        // anybody else calling the function result in a revert;
        vm.prank(alice);
        vm.expectRevert("Ownable: caller is not the owner");
        chainlinkLuckyDraw.setCandidateAddresses(candidates);
    }

    function test_get_winners() public {
        address[] memory candidates = getCandidates();
        chainlinkLuckyDraw.setCandidateAddresses(candidates);
        chainlinkLuckyDraw.setNumOfWinners(uint256(3));
        chainlinkLuckyDraw.requestRandomWords(
            chainlinkLuckyDraw.callbackGasLimit(),
            chainlinkLuckyDraw.requestConfirmations(),
            chainlinkLuckyDraw.numWords()
        );
        // I originally wanted to embed the requestRandomWords function directly into the getWinners() function
        // However, because in a testing environment, you need to fulfill the random words by manually calling the function at vrfCoordinatorV2Mock
        // So instead of that, you have to call requestRandomWords first, which would update the lastRequestId
        // And then call the vrfCoordinatorV2Mock.fulfillRandomWords(), which would fulfill the request
        // And then call the getWinners, so that you can get the winners
        // For deploying on to a real blockchain, you can modify the requestRandomWords() function directly into getWinners()
        uint256 requestId_1 = chainlinkLuckyDraw.lastRequestId();

        vrfCoordinatorV2Mock.fulfillRandomWords(
            chainlinkLuckyDraw.lastRequestId(),
            address(vRFV2Wrapper)
        );

        address[] memory winners = chainlinkLuckyDraw.getWinners();

        for (uint256 i = 0; i < winners.length; i++) {
            console.log("winners", i, winners[i]);
        }

        address[] memory historicalWinners_1 = chainlinkLuckyDraw
            .getHistoricalWinners(requestId_1);
        for (uint256 i = 0; i < winners.length; i++) {
            assertEq(winners[i], historicalWinners_1[i]);
        }

        // Let us request a new series of random Words

        chainlinkLuckyDraw.requestRandomWords(
            chainlinkLuckyDraw.callbackGasLimit(),
            chainlinkLuckyDraw.requestConfirmations(),
            chainlinkLuckyDraw.numWords()
        );
        vrfCoordinatorV2Mock.fulfillRandomWords(
            chainlinkLuckyDraw.lastRequestId(),
            address(vRFV2Wrapper)
        );
        address[] memory winners2 = chainlinkLuckyDraw.getWinners();

        for (uint256 i = 0; i < winners2.length; i++) {
            console.log("winners", i, winners2[i]);
        }
    }

    function test_can_withdraw_link() public {
        uint256 originalBalance = mockLinkToken.balanceOf(
            chainlinkLuckyDraw.owner()
        );
        uint256 contractBalanace = mockLinkToken.balanceOf(
            address(chainlinkLuckyDraw)
        );

        // only the owner can withdraw link.
        // An imposter like Alice will be humiliated.
        vm.prank(alice);
        vm.expectRevert("Ownable: caller is not the owner");
        chainlinkLuckyDraw.withdrawLink();

        chainlinkLuckyDraw.withdrawLink();
        assertEq(mockLinkToken.balanceOf(address(chainlinkLuckyDraw)), 0);
        assertEq(
            mockLinkToken.balanceOf(chainlinkLuckyDraw.owner()),
            originalBalance + contractBalanace
        );
    }

    function test_address() public view {
        for (uint256 i = 0; i <= 10; i++) {
            console.log(i, address(uint160(i)));
        }
    }

      [0x0000000000000000000000000000000000000001,
      0x0000000000000000000000000000000000000002,
      0x0000000000000000000000000000000000000003,
      0x0000000000000000000000000000000000000004,
      0x0000000000000000000000000000000000000005,
      0x0000000000000000000000000000000000000006,
      0x0000000000000000000000000000000000000007,
      0x0000000000000000000000000000000000000008,
      0x0000000000000000000000000000000000000009,
      0x000000000000000000000000000000000000000A,
      0x000000000000000000000000000000000000000B]
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
