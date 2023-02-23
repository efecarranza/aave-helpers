// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IPoolAddressesProvider, IPool, DataTypes, IReserveInterestRateStrategy} from 'aave-address-book/AaveV3.sol';
import {Initializable} from 'solidity-utils/contracts/transparent-proxy/Initializable.sol';
import {DefaultReserveInterestRateStrategy} from 'aave-v3-core/contracts/protocol/pool/DefaultReserveInterestRateStrategy.sol';
import {IDefaultInterestRateStrategy} from 'aave-v3-core/contracts/interfaces/IDefaultInterestRateStrategy.sol';
import {IV3RateStrategyFactory} from './IV3RateStrategyFactory.sol';

interface ICustomRateStrategy {
  function CUSTOM() external view returns (uint256);
}

/**
 * @title V3RateStrategyFactory
 * @notice Factory contract to create and keep record of Aave v3 of new rate strategy contracts
 * @dev Associated to an specific Aave v3 Pool, via its addresses provider
 * @author BGD labs
 */
contract V3RateStrategyFactory is Initializable, IV3RateStrategyFactory {
  IPoolAddressesProvider public immutable ADDRESSES_PROVIDER;

  mapping(bytes32 => address) internal _strategyByParamsHash;
  address[] internal _strategies;

  constructor(IPoolAddressesProvider addressesProvider) Initializable() {
    ADDRESSES_PROVIDER = addressesProvider;
  }

  function initialize() external initializer {
    refreshStrategies();
  }

  ///@inheritdoc IV3RateStrategyFactory
  function refreshStrategies() public {
    IPool pool = IPool(ADDRESSES_PROVIDER.getPool());

    address[] memory assetsListed = pool.getReservesList();
    for (uint256 i = 0; i < assetsListed.length; i++) {
      IDefaultInterestRateStrategy strat = IDefaultInterestRateStrategy(
        pool.getReserveData(assetsListed[i]).interestRateStrategyAddress
      );

      if (address(strat) != address(0)) {
        /// @dev We assume all strategies at deployment time of this factory are non-custom,
        /// by detecting the non-presence of a CUSTOM() function on them. This is correct
        /// because the current strategies don't have receive() or fallback()
        try ICustomRateStrategy(address(strat)).CUSTOM() {
          continue;
        } catch {}

        _strategyByParamsHash[
          strategyHashFromParams(
            RateStrategyParams({
              optimalUsageRatio: strat.OPTIMAL_USAGE_RATIO(),
              baseVariableBorrowRate: strat.getBaseVariableBorrowRate(),
              variableRateSlope1: strat.getVariableRateSlope1(),
              variableRateSlope2: strat.getVariableRateSlope2(),
              stableRateSlope1: strat.getStableRateSlope1(),
              stableRateSlope2: strat.getStableRateSlope2(),
              baseStableRateOffset: (strat.getBaseStableBorrowRate() > 0)
                ? (strat.getBaseStableBorrowRate() - strat.getBaseVariableBorrowRate())
                : 0, // The baseStableRateOffset is not exposed, so needs to be inferred for now
              stableRateExcessOffset: strat.getStableRateExcessOffset(),
              optimalStableToTotalDebtRatio: strat.OPTIMAL_STABLE_TO_TOTAL_DEBT_RATIO()
            })
          )
        ] = address(strat);
      }
    }
  }

  ///@inheritdoc IV3RateStrategyFactory
  function createStrategies(RateStrategyParams[] memory params) public returns (address[] memory) {
    address[] memory strategies = new address[](params.length);
    for (uint256 i = 0; i < params.length; i++) {
      bytes32 strategyHashedParams = strategyHashFromParams(params[i]);

      address cachedStrategy = _strategyByParamsHash[strategyHashedParams];

      if (cachedStrategy == address(0)) {
        cachedStrategy = address(
          new DefaultReserveInterestRateStrategy(
            ADDRESSES_PROVIDER,
            params[i].optimalUsageRatio,
            params[i].baseVariableBorrowRate,
            params[i].variableRateSlope1,
            params[i].variableRateSlope2,
            params[i].stableRateSlope1,
            params[i].stableRateSlope2,
            params[i].baseStableRateOffset,
            params[i].stableRateExcessOffset,
            params[i].optimalStableToTotalDebtRatio
          )
        );
        _strategyByParamsHash[strategyHashedParams] = cachedStrategy;
      }

      strategies[i] = cachedStrategy;
    }

    return strategies;
  }

  ///@inheritdoc IV3RateStrategyFactory
  function strategyHashFromParams(RateStrategyParams memory params) public pure returns (bytes32) {
    return
      keccak256(
        abi.encodePacked(
          params.optimalUsageRatio,
          params.baseVariableBorrowRate,
          params.variableRateSlope1,
          params.variableRateSlope2,
          params.stableRateSlope1,
          params.stableRateSlope2,
          params.baseStableRateOffset,
          params.stableRateExcessOffset,
          params.optimalStableToTotalDebtRatio
        )
      );
  }

  ///@inheritdoc IV3RateStrategyFactory
  function getAllStrategies() external view returns (address[] memory) {
    return _strategies;
  }

  ///@inheritdoc IV3RateStrategyFactory
  function getStrategyByParams(RateStrategyParams memory params) external view returns (address) {
    return _strategyByParamsHash[strategyHashFromParams(params)];
  }
}
