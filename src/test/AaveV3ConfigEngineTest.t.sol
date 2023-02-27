// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';

import {IPool} from 'aave-address-book/AaveV3.sol';
import {AaveV3Polygon} from 'aave-address-book/AaveV3Polygon.sol';
import {AaveGovernanceV2} from 'aave-address-book/AaveGovernanceV2.sol';
import {AaveMisc} from 'aave-address-book/AaveMisc.sol';
import {AaveV3ConfigEngine} from '../v3-config-engine/AaveV3ConfigEngine.sol';
import {V3RateStrategyFactory} from '../v3-config-engine/V3RateStrategyFactory.sol';
import {AaveV3PolygonMockListing} from './mocks/AaveV3PolygonMockListing.sol';
import {ITransparentProxyFactory} from 'solidity-utils/contracts/transparent-proxy/interfaces/ITransparentProxyFactory.sol';
import '../ProtocolV3TestBase.sol';

contract AaveV3ConfigEngineTest is ProtocolV3TestBase {
  using stdStorage for StdStorage;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('polygon'), 39279435);
  }

  // TODO check also by param, potentially there could be different contracts, but with exactly same params
  // function _getUniqueStrategiesOnPool(IPool pool)
  //   internal
  //   view
  //   returns (IDefaultInterestRateStrategy[] memory)
  // {
  //   address[] memory listedAssets = pool.getReservesList();
  //   IDefaultInterestRateStrategy[] memory uniqueRateStrategies = new IDefaultInterestRateStrategy[](
  //     listedAssets.length
  //   );
  //   uint256 currentIndex;
  //   for (uint256 i = 0; i < listedAssets.length; i++) {
  //     address strategy = pool.getReserveData(listedAssets[i]).interestRateStrategyAddress;
  //     for (uint256 j = 0; j < listedAssets.length; j++) {
  //       if (i == j) continue;
  //       if (strategy == pool.getReserveData(listedAssets[j]).interestRateStrategyAddress) {
  //         break;
  //       }
  //       if (j == listedAssets.length - 1) {
  //         uniqueRateStrategies[currentIndex] = IDefaultInterestRateStrategy(strategy);
  //         currentIndex++;
  //       }
  //     }
  //   }

  //   // The famous one (modify dynamic array size)
  //   assembly {
  //     mstore(uniqueRateStrategies, currentIndex)
  //   }

  //   return uniqueRateStrategies;
  // }

  function testEngine() public {
    // IDefaultInterestRateStrategy[] memory uniqueStrategies = _getUniqueStrategiesOnPool(
    //   AaveV3Polygon.POOL
    // );

    // V3RateStrategyFactory ratesFactory = V3RateStrategyFactory(
    //   ITransparentProxyFactory(AaveMisc.TRANSPARENT_PROXY_FACTORY_ETHEREUM).create(
    //     address(new V3RateStrategyFactory(AaveV3Polygon.POOL_ADDRESSES_PROVIDER)),
    //     AaveGovernanceV2.POLYGON_BRIDGE_EXECUTOR,
    //     abi.encodeWithSelector(V3RateStrategyFactory.initialize.selector, uniqueStrategies)
    //   )
    // );

    // address[] memory strategiesOnFactory = ratesFactory.getAllStrategies();
    // for (uint256 i = 0; i < strategiesOnFactory.length; i++) {
    //   emit log_address(strategiesOnFactory[i]);
    // }

    // AaveV3ConfigEngine engine = AaveV3ConfigEngine(AaveV3Polygon.LISTING_ENGINE);
    // AaveV3PolygonMockListing payload = new AaveV3PolygonMockListing();

    // vm.startPrank(AaveV3Polygon.ACL_ADMIN);
    // AaveV3Polygon.ACL_MANAGER.addPoolAdmin(address(payload));
    // vm.stopPrank();

    // ReserveConfig[] memory allConfigsBefore = _getReservesConfigs(AaveV3Polygon.POOL);

    // payload.execute();

    // ReserveConfig[] memory allConfigsAfter = _getReservesConfigs(AaveV3Polygon.POOL);

    // ReserveConfig memory expectedAssetConfig = ReserveConfig({
    //   symbol: '1INCH',
    //   underlying: 0x9c2C5fd7b07E95EE044DDeba0E97a665F142394f,
    //   aToken: address(0), // Mock, as they don't get validated, because of the "dynamic" deployment on proposal execution
    //   variableDebtToken: address(0), // Mock, as they don't get validated, because of the "dynamic" deployment on proposal execution
    //   stableDebtToken: address(0), // Mock, as they don't get validated, because of the "dynamic" deployment on proposal execution
    //   decimals: 18,
    //   ltv: 82_50,
    //   liquidationThreshold: 86_00,
    //   liquidationBonus: 105_00,
    //   liquidationProtocolFee: 10_00,
    //   reserveFactor: 10_00,
    //   usageAsCollateralEnabled: true,
    //   borrowingEnabled: true,
    //   interestRateStrategy: _findReserveConfigBySymbol(allConfigsAfter, 'AAVE')
    //     .interestRateStrategy,
    //   stableBorrowRateEnabled: false,
    //   isActive: true,
    //   isFrozen: false,
    //   isSiloed: false,
    //   isBorrowableInIsolation: false,
    //   isFlashloanable: false,
    //   supplyCap: 85_000,
    //   borrowCap: 60_000,
    //   debtCeiling: 0,
    //   eModeCategory: 0
    // });

    // _validateReserveConfig(expectedAssetConfig, allConfigsAfter);

    // _noReservesConfigsChangesApartNewListings(allConfigsBefore, allConfigsAfter);

    // _validateReserveTokensImpls(
    //   AaveV3Polygon.POOL_ADDRESSES_PROVIDER,
    //   _findReserveConfigBySymbol(allConfigsAfter, '1INCH'),
    //   ReserveTokens({
    //     aToken: engine.ATOKEN_IMPL(),
    //     stableDebtToken: engine.STOKEN_IMPL(),
    //     variableDebtToken: engine.VTOKEN_IMPL()
    //   })
    // );

    // _validateAssetSourceOnOracle(
    //   AaveV3Polygon.POOL_ADDRESSES_PROVIDER,
    //   0x9c2C5fd7b07E95EE044DDeba0E97a665F142394f,
    //   0x443C5116CdF663Eb387e72C688D276e702135C87
    // );

    // // impl should be same as e.g. WBTC
    // _validateReserveTokensImpls(
    //   AaveV3Polygon.POOL_ADDRESSES_PROVIDER,
    //   _findReserveConfigBySymbol(allConfigsAfter, 'WBTC'),
    //   ReserveTokens({
    //     aToken: engine.ATOKEN_IMPL(),
    //     stableDebtToken: engine.STOKEN_IMPL(),
    //     variableDebtToken: engine.VTOKEN_IMPL()
    //   })
    // );
  }
}
