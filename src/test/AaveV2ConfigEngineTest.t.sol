// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV2EthereumRatesUpdate} from './mocks/AaveV2EthereumRatesUpdate.sol';
import {IAaveV2ConfigEngine} from '../v2-config-engine/IAaveV2ConfigEngine.sol';
import {DeployV2EngineEthLib} from '../../script/AaveV2ConfigEngine.s.sol';
import {DeployV2RatesFactoryEthLib} from '../../script/V2RateStrategyFactory.s.sol';
import {AaveV2Ethereum} from 'aave-address-book/AaveAddressBook.sol';
import {AaveV2EthereumAssets} from 'aave-address-book/AaveV2Ethereum.sol';
import {AaveGovernanceV2} from 'aave-address-book/AaveGovernanceV2.sol';
import {IV2RateStrategyFactory} from '../v2-config-engine/IV2RateStrategyFactory.sol';
import {TestWithExecutor} from '../GovHelpers.sol';
import '../ProtocolV2TestBase.sol';

contract AaveV2ConfigEngineTest is ProtocolV2TestBase, TestWithExecutor {
  using stdStorage for StdStorage;

  function testV2RateStrategiesUpdates() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), 16727659);
    (address ratesFactory, ) = DeployV2RatesFactoryEthLib.deploy();
    IAaveV2ConfigEngine engine = IAaveV2ConfigEngine(DeployV2EngineEthLib.deploy(ratesFactory));

    AaveV2EthereumRatesUpdate payload = new AaveV2EthereumRatesUpdate(engine);

    address initialStrategyAddress = AaveV2Ethereum.POOL.getReserveData(AaveV2EthereumAssets.USDC_UNDERLYING).interestRateStrategyAddress;
    IDefaultInterestRateStrategy initialStrategy = IDefaultInterestRateStrategy(
      initialStrategyAddress
    );

    createConfigurationSnapshot('preTestV2RatesUpdates', AaveV2Ethereum.POOL);

    _selectPayloadExecutor(AaveGovernanceV2.SHORT_EXECUTOR);
    _executor.execute(address(payload));

    createConfigurationSnapshot('postTestV2RatesUpdates', AaveV2Ethereum.POOL);

    diffReports('preTestV2RatesUpdates', 'postTestV2RatesUpdates');

    address updatedStrategyAddress = AaveV2Ethereum.POOL.getReserveData(AaveV2EthereumAssets.USDC_UNDERLYING).interestRateStrategyAddress;

    InterestStrategyValues memory expectedInterestStrategyValues = InterestStrategyValues({
      addressesProvider: address(AaveV2Ethereum.POOL_ADDRESSES_PROVIDER),
      optimalUsageRatio: _bpsToRay(69_00),
      baseVariableBorrowRate: initialStrategy.baseVariableBorrowRate(),
      variableRateSlope1: _bpsToRay(42_00),
      variableRateSlope2: initialStrategy.variableRateSlope2(),
      stableRateSlope1: _bpsToRay(69_00),
      stableRateSlope2: initialStrategy.stableRateSlope2()
    });

    _validateInterestRateStrategy(
      updatedStrategyAddress,
      updatedStrategyAddress,
      expectedInterestStrategyValues
    );
  }

  function _bpsToRay(uint256 amount) internal pure returns (uint256) {
    return (amount * 1e27) / 10_000;
  }
}