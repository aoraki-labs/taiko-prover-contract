// // SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {ProverFactory} from "../src/ProverFactory.sol";
import {Prover} from "../src/Prover.sol";

contract ProverFactoryTest is Test {
    uint256 private _seed = 0x12345678;

    function getRandomAddress() internal returns (address) {
        bytes32 randomHash = keccak256(abi.encodePacked("address", _seed++));
        return address(bytes20(randomHash));
    }

    address internal Alice = getRandomAddress();
    address internal Bob = getRandomAddress();
    address internal Carol = getRandomAddress();

    ProverFactory public proverFactory;

    function setUp() public {
        proverFactory = new ProverFactory();
    }

    function test_createProver() public {
        address aliceProver = proverFactory.createProver(Alice);
        assertEq(Prover(aliceProver).owner(), Alice);

        address bobProver = proverFactory.createProver(Bob);
        assertEq(Prover(bobProver).owner(), Bob);

        address carolProver = proverFactory.createProver(Carol);
        assertEq(Prover(carolProver).owner(), Carol);
    }
}
