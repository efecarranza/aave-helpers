// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';

import {AaveV3Polygon, AaveV3PolygonAssets} from 'aave-address-book/AaveV3Polygon.sol';
import {AaveGovernanceV2} from 'aave-address-book/AaveGovernanceV2.sol';
import {AaveMisc} from 'aave-address-book/AaveMisc.sol';
import {IAaveV3ConfigEngine} from '../v3-config-engine/IAaveV3ConfigEngine.sol';
import {IV3RateStrategyFactory} from '../v3-config-engine/V3RateStrategyFactory.sol';
import {AaveV3PolygonMockListing} from './mocks/AaveV3PolygonMockListing.sol';
import {ITransparentProxyFactory} from 'solidity-utils/contracts/transparent-proxy/interfaces/ITransparentProxyFactory.sol';
import {DeployRatesFactoryPolLib} from '../../script/V3RateStrategyFactory.s.sol';
import {DeployEnginePolLib} from '../../script/AaveV3ConfigEngine.s.sol';
import '../ProtocolV3TestBase.sol';

contract AaveV3ConfigEngineTest is ProtocolV3TestBase {
  using stdStorage for StdStorage;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('polygon'), 39797440);
  }

  function testEngine() public {
    (address ratesFactory, ) = DeployRatesFactoryPolLib.deploy();

    IAaveV3ConfigEngine engine = IAaveV3ConfigEngine(DeployEnginePolLib.deploy(ratesFactory));
    AaveV3PolygonMockListing payload = new AaveV3PolygonMockListing(engine);

    vm.startPrank(AaveV3Polygon.ACL_ADMIN);
    AaveV3Polygon.ACL_MANAGER.addPoolAdmin(address(payload));
    vm.stopPrank();

    // createConfigurationSnapshot('preTestEngine', AaveV3Polygon.POOL);

    ReserveConfig[] memory allConfigsBefore = _getReservesConfigs(AaveV3Polygon.POOL);

    payload.execute();

    // createConfigurationSnapshot('postTestEngine', AaveV3Polygon.POOL);

    // diffReports('preTestEngine', 'postTestEngine');

    ReserveConfig[] memory allConfigsAfter = _getReservesConfigs(AaveV3Polygon.POOL);

    ReserveConfig memory expectedAssetConfig = ReserveConfig({
      symbol: '1INCH',
      underlying: 0x9c2C5fd7b07E95EE044DDeba0E97a665F142394f,
      aToken: address(0), // Mock, as they don't get validated, because of the "dynamic" deployment on proposal execution
      variableDebtToken: address(0), // Mock, as they don't get validated, because of the "dynamic" deployment on proposal execution
      stableDebtToken: address(0), // Mock, as they don't get validated, because of the "dynamic" deployment on proposal execution
      decimals: 18,
      ltv: 82_50,
      liquidationThreshold: 86_00,
      liquidationBonus: 105_00,
      liquidationProtocolFee: 10_00,
      reserveFactor: 10_00,
      usageAsCollateralEnabled: true,
      borrowingEnabled: true,
      interestRateStrategy: _findReserveConfigBySymbol(allConfigsAfter, 'AAVE')
        .interestRateStrategy,
      stableBorrowRateEnabled: false,
      isActive: true,
      isFrozen: false,
      isSiloed: false,
      isBorrowableInIsolation: false,
      isFlashloanable: false,
      supplyCap: 85_000,
      borrowCap: 60_000,
      debtCeiling: 0,
      eModeCategory: 0
    });

    _validateReserveConfig(expectedAssetConfig, allConfigsAfter);

    _noReservesConfigsChangesApartNewListings(allConfigsBefore, allConfigsAfter);

    _validateReserveTokensImpls(
      AaveV3Polygon.POOL_ADDRESSES_PROVIDER,
      _findReserveConfigBySymbol(allConfigsAfter, '1INCH'),
      ReserveTokens({
        aToken: engine.ATOKEN_IMPL(),
        stableDebtToken: engine.STOKEN_IMPL(),
        variableDebtToken: engine.VTOKEN_IMPL()
      })
    );

    _validateAssetSourceOnOracle(
      AaveV3Polygon.POOL_ADDRESSES_PROVIDER,
      0x9c2C5fd7b07E95EE044DDeba0E97a665F142394f,
      0x443C5116CdF663Eb387e72C688D276e702135C87
    );

    // impl should be same as e.g. AAVE
    _validateReserveTokensImpls(
      AaveV3Polygon.POOL_ADDRESSES_PROVIDER,
      _findReserveConfigBySymbol(allConfigsAfter, 'AAVE'),
      ReserveTokens({
        aToken: engine.ATOKEN_IMPL(),
        stableDebtToken: engine.STOKEN_IMPL(),
        variableDebtToken: engine.VTOKEN_IMPL()
      })
    );
  }
}
