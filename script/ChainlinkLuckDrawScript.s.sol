// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {ChainlinkLuckyDraw} from "../src/ChainlinkLuckyDraw.sol";
import "forge-std/Script.sol";
import {BaseScript} from "./BaseScript.s.sol";

contract ChainlinkLuckDrawScript is BaseScript {
    function setUp() public {}

    // Address LINK - hardcoded for Sepolia
    address linkAddress = 0x779877A7B0D9E8603169DdbD7836e478b4624789;

    // address WRAPPER - hardcoded for Sepolia
    address wrapperAddress = 0xab18414CD93297B0d12ac29E63Ca20f515b3DB46;

    function run() public broadcaster {
        ChainlinkLuckyDraw chainlinkLuckyDraw = new ChainlinkLuckyDraw(
            linkAddress,
            wrapperAddress
        );
    }
}
