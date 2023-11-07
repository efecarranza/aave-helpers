// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IAavePolEthERC20Bridge {
  /*
   * This function withdraws an ERC20 token from Polygon to Mainnet. exit() needs
   * to be called on mainnet with the corresponding burnProof in order to complete.
   * @notice Polygon only. Function will revert if called from other network.
   * @param token Polygon address of ERC20 token to withdraw
   * @param amount Amount of tokens to withdraw
   */
  function bridge(address token, uint256 amount) external;

  /*
   * This function completes the withdrawal process from Polygon to Mainnet.
   * Burn proof is generated via API. Please see README.md
   * @notice Mainnet only. Function will revert if called from other network.
   * @param burnProof Burn proof generated via API.
   */
  function exit(bytes calldata burnProof) external;

  /*
   * This function completes the withdrawal process from Polygon to Mainnet.
   * Burn proofs are generated via API. Please see README.md
   * @notice Mainnet only. Function will revert if called from other network.
   * @param burnProofs Array of burn proofs generated via API.
   */
  function exit(bytes[] calldata burnProofs) external;

  /*
   * Withdraws tokens on Mainnet contract to Aave V3 Collector.
   * @notice Mainnet only. Function will revert if called from other network.
   * @param token Mainnet address of token to withdraw to Collector
   */
  function withdrawToCollector(address token) external;
}
