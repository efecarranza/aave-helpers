// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IAaveOpEthERC20Bridge {
  /// @notice Returned when calling the contract from an invalid chain
  error InvalidChain();

  /// @notice Emitted when bridging a token from Optimism to Mainnet
  event Bridge(address indexed token, uint256 amount);

  function bridge(address token, address l1Token, uint256 amount) external;
}
