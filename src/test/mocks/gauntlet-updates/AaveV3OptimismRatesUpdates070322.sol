// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '../../../v3-config-engine/AaveV3PayloadBase.sol';
import {AaveV3Optimism, AaveV3OptimismAssets} from 'aave-address-book/AaveV3Optimism.sol';

/**
 * @dev Payload for the initial rates update defined here on:
 * https://snapshot.org/#/aave.eth/proposal/0xbda28d65ca4d64005e6019948ed52d9d62c9e73e356ab1013aa2d4829f40c735
 * @author BGD Labs
 */
contract AaveV3OptimismRatesUpdates070322 is AaveV3PayloadBase {
  // TODO remove custom engine once available on address book
  // TODO add RF changes once helper available on engine
  constructor(IEngine customEngine) AaveV3PayloadBase(customEngine) {}

  function rateStrategiesUpdates()
    public
    view
    override
    returns (IEngine.RateStrategyUpdate[] memory)
  {
    IEngine.RateStrategyUpdate[] memory ratesUpdate = new IEngine.RateStrategyUpdate[](2);

    Rates.RateStrategyParams memory usdt = LISTING_ENGINE
      .RATE_STRATEGIES_FACTORY()
      .getCurrentRateData(AaveV3OptimismAssets.USDT_UNDERLYING);
    usdt.optimalUsageRatio = _bpsToRay(80_00);
    usdt.variableRateSlope2 = _bpsToRay(75_00);
    usdt.stableRateSlope2 = _bpsToRay(75_00);

    ratesUpdate[0] = IEngine.RateStrategyUpdate({
      asset: AaveV3OptimismAssets.USDT_UNDERLYING,
      params: usdt
    });

    ratesUpdate[1] = IEngine.RateStrategyUpdate({
      asset: AaveV3OptimismAssets.WETH_UNDERLYING,
      params: Rates.RateStrategyParams({
        optimalUsageRatio: _bpsToRay(80_00),
        baseVariableBorrowRate: _bpsToRay(1_00),
        variableRateSlope1: _bpsToRay(3_80),
        variableRateSlope2: _bpsToRay(80_00),
        stableRateSlope1: _bpsToRay(4_00),
        stableRateSlope2: _bpsToRay(80_00),
        baseStableRateOffset: _bpsToRay(3_00),
        stableRateExcessOffset: EngineFlags.KEEP_CURRENT,
        optimalStableToTotalDebtRatio: EngineFlags.KEEP_CURRENT
      })
    });

    return ratesUpdate;
  }

  function getPoolContext() public pure override returns (IEngine.PoolContext memory) {
    return IEngine.PoolContext({networkName: 'Optimism', networkAbbreviation: 'Opt'});
  }
}
