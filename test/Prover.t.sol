// // SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {ProverFactory} from "../src/ProverFactory.sol";
import {Prover} from "../src/Prover.sol";
import {BlockMetadataInput, ProverAssignment} from "../src/interfaces/IProver.sol";
import {RegularERC20} from "./RegularERC20.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC165Checker} from "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";

contract ProverTest is Test {
    uint256 private _seed = 0x12345678;

    function getRandomAddress() internal returns (address) {
        bytes32 randomHash = keccak256(abi.encodePacked("address", _seed++));
        return address(bytes20(randomHash));
    }

    ProverFactory public proverFactory;
    Prover public prover;
    RegularERC20 public token;

    uint256 internal ownerPrivateKey;
    address internal owner;

    address internal proposer;

    function setUp() public {
        ownerPrivateKey = 0xA11CE;
        owner = vm.addr(ownerPrivateKey);

        proverFactory = new ProverFactory();
        prover = Prover(proverFactory.createProver(owner));

        proposer = getRandomAddress();

        vm.startPrank(proposer);
        token = new RegularERC20(100 ether);
        token.approve(address(prover), 10 ether);
        vm.stopPrank();
    }

    function test_owner() public {
        assertEq(prover.owner(), owner);
    }

    function test_withdraw() public {
        vm.startPrank(proposer);
        token.transfer(address(prover), 1 ether);
        vm.stopPrank();
        assertEq(token.balanceOf(address(prover)), 1 ether);

        prover.withdraw(address(token));
        assertEq(token.balanceOf(prover.owner()), 1 ether);
    }

    function test_onBlockAssigned() public {
        uint64 blockId = 100;
        uint24 txListSize = 10;
        bytes memory txList = new bytes(txListSize);
        BlockMetadataInput memory input = BlockMetadataInput({
            txListHash: keccak256(txList),
            proposer: proposer,
            txListByteStart: 0,
            txListByteEnd: txListSize,
            cacheTxListInfo: false
        });

        uint256 amount = 1 ether;
        uint64 expiry = 5 minutes;

        bytes32 assignmentHash = keccak256(abi.encode(input, address(token), amount, expiry));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, assignmentHash);
        bytes memory signature = abi.encodePacked(r, s, v);

        Prover.ExpandedData memory expandedData =
            Prover.ExpandedData({token: address(token), amount: amount, signature: signature});

        ProverAssignment memory assignment =
            ProverAssignment({prover: address(prover), expiry: 5 minutes, data: abi.encode(expandedData)});

        prover.onBlockAssigned(blockId, input, assignment);

        assertEq(token.balanceOf(address(prover)), 1 ether);
    }
}
