// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.8.10;

import {IPoolAddressesProvider} from 'aave-address-book/AaveV3.sol';

interface IV3RateStrategyFactory {
  event RateStrategyCreated(address indexed strategy);

  struct RateStrategyParams {
    uint256 optimalUsageRatio;
    uint256 baseVariableBorrowRate;
    uint256 variableRateSlope1;
    uint256 variableRateSlope2;
    uint256 stableRateSlope1;
    uint256 stableRateSlope2;
    uint256 baseStableRateOffset;
    uint256 stableRateExcessOffset;
    uint256 optimalStableToTotalDebtRatio;
  }

  function createStrategies(RateStrategyParams[] memory params) external returns (address[] memory);

  function refreshStrategies() external;

  function strategyHashFromParams(RateStrategyParams memory params) external pure returns (bytes32);

  /**
   * @notice Returns all the strategies registered in the factory
   * @return address[] list of strategies
   */
  function getAllStrategies() external view returns (address[] memory);

  /**
   * @notice Returns the a strategy added, given its parameters.
   * @dev Only if the strategy is registered in the factory.
   * @param params `RateStrategyParams` the parameters of the rate strategy
   * @return address the address of the strategy
   */
  function getStrategyByParams(RateStrategyParams memory params) external view returns (address);

  function ADDRESSES_PROVIDER() external view returns (IPoolAddressesProvider);
}
