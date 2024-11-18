// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IFinanceSteward {
  /**
   * @notice object with stream parameters
   * @param token ERC20 compatible asset
   * @param amount streamed amount in wei
   * @param start of the stream in timestamp
   * @param end of the stream in timestamp
   */
  struct StreamData {
    address token;
    uint256 amount;
    uint256 start;
    uint256 end;
  }

  /// @notice Emitted when the budget for a token is updated
  /// @param token The address of the token
  /// @param newAmount The new budget amount
  event BudgetUpdate(address indexed token, uint newAmount);

  /// @notice Emitted when a token is approved for swapping with its corresponding USD oracle
  /// @param token The address of the token approved for swapping
  /// @param oracleUSD The address of the oracle providing the USD price feed for the token
  event SwapApprovedToken(address indexed token, address indexed oracleUSD);

  /// @notice Emitted when a new V3 Pool gets listed
  /// @param V3Pool The address of the new pool
  event AddedV3Pool(address indexed V3Pool);

  /// @notice Emitted when an address is whitelisted as a receiver for transfers
  /// @param receiver The address that has been whitelisted
  event ReceiverWhitelisted(address indexed receiver);

  /// @notice Emitted when the minimum balance for a token is updated
  /// @param token The address of the token
  /// @param newAmount The new minimum balance for the token
  event MinimumTokenBalanceUpdated(address indexed token, uint newAmount);

  /// @notice Deposits a specified amount of a reserve token into Aave V3
  /// @param reserve The address of the V3 Pool to deposit
  /// @param reserve The address of the reserve token
  /// @param amount The amount of the reserve token to deposit
  function depositV3(address V3Pool, address reserve, uint amount) external;

  /// @notice Migrates a specified amount of a reserve token from Aave V2 to Aave V3
  /// @param reserve The address of the reserve token
  /// @param amount The amount of the reserve token to migrate
  /// @param V3Pool The address of the destination V3 Pool
  function migrateV2toV3(address reserve, uint amount, address V3Pool) external;

  /// @notice Withdraws a specified amount of a reserve token from Aave V2
  /// @param reserve The address of the reserve token to withdraw
  /// @param amount The amount of the reserve token to withdraw
  function withdrawV2(address reserve, uint amount) external;

  /// @notice Withdraws a specified amount of a reserve token from Aave V3
  /// @param V3Pool The address of the V3 pool to withdraw from
  /// @param reserve The address of the reserve token to withdraw
  /// @param amount The amount of the reserve token to withdraw
  function withdrawV3(address V3Pool, address reserve, uint amount) external;

  /// @notice Withdraws a specified amount of a reserve token from Aave V2 and swaps it for another token
  /// @param reserve The address of the reserve token to withdraw
  /// @param amount The amount of the reserve token to withdraw
  /// @param buyToken The address of the token to buy with the withdrawn reserve token
  /// @param slippage The slippage allowed in the swap
  function withdrawV2andSwap(
    address reserve,
    uint amount,
    address buyToken,
    uint256 slippage
  ) external;

  /// @notice Withdraws a specified amount of a reserve token from Aave V3 and swaps it for another token
  /// @param V3Pool The address of the V3 Pool to withdraw from
  /// @param reserve The address of the reserve token to withdraw
  /// @param amount The amount of the reserve token to withdraw
  /// @param buyToken The address of the token to buy with the withdrawn reserve token
  /// @param slippage The slippage allowed in the swap
  function withdrawV3andSwap(
    address V3Pool,
    address reserve,
    uint amount,
    address buyToken,
    uint256 slippage
  ) external;

  /// @notice Swaps a specified amount of a sell token for a buy token
  /// @param sellToken The address of the token to sell
  /// @param amount The amount of the sell token to swap
  /// @param buyToken The address of the token to buy
  /// @param slippage The slippage allowed in the swap
  function tokenSwap(
    address sellToken,
    uint256 amount,
    address buyToken,
    uint256 slippage
  ) external;

  /// @notice Approves a specified amount of a token for transfer to a recipient
  /// @param token The address of the token to approve
  /// @param to The address of the recipient
  /// @param amount The amount of the token to approve
  function approve(address token, address to, uint256 amount) external;

  /// @notice Transfers a specified amount of a token to a recipient
  /// @param token The address of the token to transfer
  /// @param to The address of the recipient
  /// @param amount The amount of the token to transfer
  function transfer(address token, address to, uint256 amount) external;

  /// @notice Creates a stream to transfer a specified amount of a token to a recipient over a duration
  /// @param to The address of the recipient
  /// @param stream Object including token, amount, start, end
  function createStream(address to, StreamData memory stream) external;

  /// @notice Cancels a stream identified by the streamId
  /// @param streamId The ID of the stream to cancel
  function cancelStream(uint256 streamId) external;

  /// @notice Increases the budget for a specified token by a specified amount
  /// @param token The address of the token
  /// @param amount The amount to increase the budget by
  function increaseBudget(address token, uint256 amount) external;

  /// @notice Decreases the budget for a specified token by a specified amount
  /// @param token The address of the token
  /// @param amount The amount to decrease the budget by
  function decreaseBudget(address token, uint256 amount) external;

  /// @notice Sets the address for the MILKMAN used in swaps
  /// @param to The address of MILKMAN
  function setMilkman(address to) external;

  /// @notice Sets the address for the Price checker used in swaps
  /// @param to The address of PRICE_CHECKER
  function setPriceChecker(address to) external;

  /// @notice Sets the address for the swapper contract
  /// @param to The address of SWAPPER
  function setSwapper(address to) external;

  /// @notice Sets a token as swappable and provides its price feed address
  /// @param token The address of the token to set as swappable
  /// @param priceFeedUSD The address of the price feed for the token
  function setSwappableToken(address token, address priceFeedUSD) external;

  /// @notice Sets an address as a whitelisted receiver for transfers
  /// @param to The address to whitelist
  function setWhitelistedReceiver(address to) external;

  /// @notice Sets the minimum balance shield for a specified token
  /// @param token The address of the token
  /// @param amount The minimum balance to shield
  function setMinimumBalanceShield(address token, uint amount) external;
}
