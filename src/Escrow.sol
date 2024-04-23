// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

contract Escrow {
    using SafeERC20 for IERC20;

    error AlreadyInitialized();
    error NotOwner();
    error NativeTransferFailed();

    address internal owner;

    receive() external payable {}

    fallback() external payable {}

    /// @notice Initializes the Escrow with the sender of the transaction as owner.
    /// @dev This should be called in the same transaction as deploying the escrow, to prevent front running.
    function __Escrow_init() public payable {
        if (owner != address(0)) {
            revert AlreadyInitialized();
        }

        owner = msg.sender;
    }

    /// @notice Transfers a certain amount of ERC20 token to a given address. Can only be called by the owner.
    /// @param token The ERC20 contract address.
    /// @param to The address to receive the tokens.
    /// @param amount The amount of ERC20 token to receive.
    /// @dev Wont do anything if amount is 0.
    function transfer(IERC20 token, address to, uint256 amount) external {
        if (msg.sender != owner) {
            revert NotOwner();
        }

        if (amount != 0) {
            token.safeTransfer(to, amount);
        }
    }

    /// @notice Transfers a certain amount of native currency to a given address. Can only be called by the owner.
    /// @param to The address to receive the currency.
    /// @param amount The amount of native currency to receive.
    /// @dev Wont do anything if amount is 0.
    function transferNative(address payable to, uint256 amount) external {
        if (msg.sender != owner) {
            revert NotOwner();
        }

        if (amount != 0) {
            // Use call instead of transfer for correct gas estimation to smart contracts
            (bool success,) = to.call{value: amount}("");
            if (!success) {
                revert NativeTransferFailed();
            }
        }
    }
}
