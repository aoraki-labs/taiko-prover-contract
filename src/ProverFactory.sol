// SPDX-License-Identifier: MIT
//     _    ___  ____     _    _  _____    _        _    ____ ____
//    / \  / _ \|  _ \   / \  | |/ |_ _|  | |      / \  | __ / ___|
//   / _ \| | | | |_) | / _ \ | ' / | |   | |     / _ \ |  _ \___ \
//  / ___ | |_| |  _ < / ___ \| . \ | |   | |___ / ___ \| |_) ___) |
// /_/   \_\___/|_| \_/_/   \_|_|\_|___|  |_____/_/   \_|____|____/

pragma solidity ^0.8.20;

import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {Prover} from "./Prover.sol";

contract ProverFactory {

    event ProverCreated(
        address indexed prover,
        address indexed owner
    );

    address immutable proverImplementation;

    constructor() {
        proverImplementation = address(new Prover());
    }

    function createProver(address owner) external returns (address) {
        address clone = Clones.clone(proverImplementation);
        Prover(clone).initialize(owner);

        emit ProverCreated(clone, owner);

        return clone;
    }
}
