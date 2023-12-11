// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IQuestDistributor {
  /**
   * @notice Checks if the rewards were claimed for an index
   * @dev Checks if the rewards were claimed for an index for the current update
   * @param token addredd of the token to claim
   * @param index Index of the claim
   * @return bool : true if already claimed
   */
  function isClaimed(address token, uint256 index) external view returns (bool);

  /**
   * @notice Claims rewards for a given token for the user
   * @dev Claims the reward for an user for the current update of the Merkle Root for the given token
   * @param token Address of the token to claim
   * @param index Index in the Merkle Tree
   * @param account Address of the user claiming the rewards
   * @param amount Amount of rewards to claim
   * @param merkleProof Proof to claim the rewards
   */
  function claim(
    address token,
    uint256 index,
    address account,
    uint256 amount,
    bytes32[] calldata merkleProof
  ) external;
}
