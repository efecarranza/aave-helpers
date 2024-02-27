// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IAavePolEthPlasmaBridge {
  /// This function withdraws an ERC20 token from Polygon to Mainnet. exit() needs
  /// to be called on mainnet with the corresponding burnProof in order to complete.
  /// @notice Polygon only. Function will revert if called from other network.
  /// @param token Polygon address of ERC20 token to withdraw
  /// @param amount Amount of tokens to withdraw
  function bridge(address token, uint256 amount) external;
}
