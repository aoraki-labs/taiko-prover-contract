// SPDX-License-Identifier: MIT
//     _    ___  ____     _    _  _____    _        _    ____ ____
//    / \  / _ \|  _ \   / \  | |/ |_ _|  | |      / \  | __ / ___|
//   / _ \| | | | |_) | / _ \ | ' / | |   | |     / _ \ |  _ \___ \
//  / ___ | |_| |  _ < / ___ \| . \ | |   | |___ / ___ \| |_) ___) |
// /_/   \_\___/|_| \_/_/   \_|_|\_|___|  |_____/_/   \_|____|____/

pragma solidity ^0.8.20;

struct BlockMetadataInput {
    bytes32 txListHash;
    address proposer;
    uint24 txListByteStart; // byte-wise start index (inclusive)
    uint24 txListByteEnd; // byte-wise end index (exclusive)
    bool cacheTxListInfo;
}

struct ProverAssignment {
    address prover;
    uint64 expiry;
    bytes data;
}

interface IProver {
    function onBlockAssigned(
        uint64 blockId,
        BlockMetadataInput calldata input,
        ProverAssignment calldata assignment
    )
        external
        payable;
}
