// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';

import {AaveV3Polygon, AaveV3PolygonAssets} from 'aave-address-book/AaveV3Polygon.sol';
import {AaveV3Avalanche, AaveV3AvalancheAssets} from 'aave-address-book/AaveV3Avalanche.sol';
import {AaveV3Optimism, AaveV3OptimismAssets} from 'aave-address-book/AaveV3Optimism.sol';
import {AaveV3Arbitrum, AaveV3ArbitrumAssets} from 'aave-address-book/AaveV3Arbitrum.sol';
import {AaveV3Ethereum} from 'aave-address-book/AaveV3Ethereum.sol';
import {AaveGovernanceV2} from 'aave-address-book/AaveGovernanceV2.sol';
import {IAaveV3ConfigEngine} from '../v3-config-engine/IAaveV3ConfigEngine.sol';
import {AaveV3PolygonRatesUpdates070322} from './mocks/gauntlet-updates/AaveV3PolygonRatesUpdates070322.sol';
import {AaveV3AvalancheRatesUpdates070322} from './mocks/gauntlet-updates/AaveV3AvalancheRatesUpdates070322.sol';
import {AaveV3OptimismRatesUpdates070322} from './mocks/gauntlet-updates/AaveV3OptimismRatesUpdates070322.sol';
import {AaveV3ArbitrumRatesUpdates070322} from './mocks/gauntlet-updates/AaveV3ArbitrumRatesUpdates070322.sol';
import {DeployEnginePolLib, DeployEngineEthLib, DeployEngineAvaLib, DeployEngineOptLib, DeployEngineArbLib} from '../../script/AaveV3ConfigEngine.s.sol';
import {TestWithExecutor} from '../GovHelpers.sol';
import '../ProtocolV3TestBase.sol';

contract AaveV3PolygonConfigEngineRatesTest is ProtocolV3TestBase, TestWithExecutor {
  using stdStorage for StdStorage;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('polygon'), 40037250);
    _selectPayloadExecutor(AaveGovernanceV2.POLYGON_BRIDGE_EXECUTOR);
  }

  function testEngine() public {
    IAaveV3ConfigEngine engine = IAaveV3ConfigEngine(
      DeployEnginePolLib.deploy(0xcC47c4Fe1F7f29ff31A8b62197023aC8553C7896)
    );
    AaveV3PolygonRatesUpdates070322 payload = new AaveV3PolygonRatesUpdates070322(engine);

    createConfigurationSnapshot('preTestEnginePolV3', AaveV3Polygon.POOL);

    _executePayload(address(payload));

    createConfigurationSnapshot('postTestEnginePolV3', AaveV3Polygon.POOL);

    diffReports('preTestEnginePolV3', 'postTestEnginePolV3');
  }
}

contract AaveV3AvalancheConfigEngineRatesTest is ProtocolV3TestBase, TestWithExecutor {
  using stdStorage for StdStorage;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('avalanche'), 27094357);
    _selectPayloadExecutor(0xa35b76E4935449E33C56aB24b23fcd3246f13470); // Aave Avalanche's Guardian
  }

  function testEngine() public {
    IAaveV3ConfigEngine engine = IAaveV3ConfigEngine(
      DeployEngineAvaLib.deploy(0xDd81E6F85358292075B78fc8D5830BE8434aF8BA)
    );
    AaveV3AvalancheRatesUpdates070322 payload = new AaveV3AvalancheRatesUpdates070322(engine);

    createConfigurationSnapshot('preTestEngineAvaV3', AaveV3Avalanche.POOL);

    _executePayload(address(payload));

    createConfigurationSnapshot('postTestEngineAvaV3', AaveV3Avalanche.POOL);

    diffReports('preTestEngineAvaV3', 'postTestEngineAvaV3');
  }
}

contract AaveV3OptimismConfigEngineRatesTest is ProtocolV3TestBase, TestWithExecutor {
  using stdStorage for StdStorage;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('optimism'), 78907810);
    _selectPayloadExecutor(AaveGovernanceV2.OPTIMISM_BRIDGE_EXECUTOR);
  }

  function testEngine() public {
    IAaveV3ConfigEngine engine = IAaveV3ConfigEngine(
      DeployEngineAvaLib.deploy(0xDd81E6F85358292075B78fc8D5830BE8434aF8BA)
    );
    AaveV3OptimismRatesUpdates070322 payload = new AaveV3OptimismRatesUpdates070322(engine);

    createConfigurationSnapshot('preTestEngineOptV3', AaveV3Optimism.POOL);

    _executePayload(address(payload));

    createConfigurationSnapshot('postTestEngineOptV3', AaveV3Optimism.POOL);

    diffReports('preTestEngineOptV3', 'postTestEngineOptV3');
  }
}

contract AaveV3ArbitrumConfigEngineRatesTest is ProtocolV3TestBase, TestWithExecutor {
  using stdStorage for StdStorage;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('arbitrum'), 67332070);
    _selectPayloadExecutor(AaveGovernanceV2.ARBITRUM_BRIDGE_EXECUTOR);
  }

  function testEngine() public {
    IAaveV3ConfigEngine engine = IAaveV3ConfigEngine(
      DeployEngineAvaLib.deploy(0xcC47c4Fe1F7f29ff31A8b62197023aC8553C7896)
    );
    AaveV3ArbitrumRatesUpdates070322 payload = new AaveV3ArbitrumRatesUpdates070322(engine);

    vm.startPrank(AaveV3Arbitrum.ACL_ADMIN);
    AaveV3Arbitrum.ACL_MANAGER.addPoolAdmin(address(payload));
    vm.stopPrank();

    createConfigurationSnapshot('preTestEngineArbV3', AaveV3Arbitrum.POOL);

    payload.execute();

    createConfigurationSnapshot('postTestEngineArbV3', AaveV3Arbitrum.POOL);

    diffReports('preTestEngineArbV3', 'postTestEngineArbV3');
  }
}
