// SPDX-License-Identifier: MIT
//     _    ___  ____     _    _  _____    _        _    ____ ____  
//    / \  / _ \|  _ \   / \  | |/ |_ _|  | |      / \  | __ / ___| 
//   / _ \| | | | |_) | / _ \ | ' / | |   | |     / _ \ |  _ \___ \ 
//  / ___ | |_| |  _ < / ___ \| . \ | |   | |___ / ___ \| |_) ___) |
// /_/   \_\___/|_| \_/_/   \_|_|\_|___|  |_____/_/   \_|____|____/ 

pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {OwnableUpgradeable} 
    from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {Initializable}
    from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {
    BlockMetadataInput,
    IProver,
    ProverAssignment
} from "./interfaces/IProver.sol";




contract Prover is IProver, Initializable, OwnableUpgradeable {
    using ECDSA for bytes32;

    struct ExpandedData {
        address token;
        uint256 amount;
        bytes signature;
    }

    
    event PaymentSucceeded(
        address indexed token,
        address indexed prover,
        uint256 amount,
        uint64 expiry
    );

    error InvalidProverSignature();
    error NotERC20(address token);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function initialize(address _owner) 
        public
        initializer
    {
        __Ownable_init(_owner);
    }

    function onBlockAssigned(
        uint64,
        BlockMetadataInput calldata input,
        ProverAssignment calldata assignment
    ) 
        external
        payable
    {
        ExpandedData memory expandedData 
            = abi.decode(assignment.data, (ExpandedData));

        if (
            _hashAssignment(
                input,
                assignment,
                expandedData
            ).recover(expandedData.signature) != owner()
        ) {
            revert InvalidProverSignature();
        }

        IERC20(expandedData.token).transferFrom(
            input.proposer,
            assignment.prover,
            expandedData.amount
        );

        emit PaymentSucceeded({
            token: expandedData.token,
            prover: assignment.prover,
            amount: expandedData.amount,
            expiry: assignment.expiry
        });
    }

    function withdraw(address _token) external {
        uint amount = IERC20(_token).balanceOf(address(this));
        IERC20(_token).transfer(owner(), amount);
    }

    function _hashAssignment(
        BlockMetadataInput memory input,
        ProverAssignment memory assignment,
        ExpandedData memory expandedData
    )
        private
        pure
        returns (bytes32)
    {
        return keccak256(
            abi.encode(
                input,
                expandedData.token,
                expandedData.amount,
                assignment.expiry
            )
        );
    }

}