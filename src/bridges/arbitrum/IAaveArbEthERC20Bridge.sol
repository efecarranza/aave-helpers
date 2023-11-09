// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

interface IAaveArbEthERC20Bridge {
  /*
   * Returns the address of the Arbitrum contract to bridge tokens from
   */
  function ARBITRUM_GATEWAY() external view returns (address);

  /*
   * Returns the address of the Mainnet contract to exit the bridge from
   */
  function MAINNET_OUTBOX() external view returns (address);

  /*
   * This function withdraws an ERC20 token from Polygon to Mainnet. exit() needs
   * to be called on mainnet with the corresponding burnProof in order to complete.
   * @notice Polygon only. Function will revert if called from other network.
   * @param token Polygon address of ERC20 token to withdraw
   * @param amount Amount of tokens to withdraw
   */
  function bridge(address token, uint256 amount) external;

  /*
   * This function completes the withdrawal process from Arbitrum to Mainnet.
   * Burn proof is generated via API. Please see README.md
   * @notice Mainnet only. Function will revert if called from other network.
   * @param burnProof Burn proof generated via API.
   */
  function exit() external;
}
