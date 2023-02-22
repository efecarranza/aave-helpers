// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from 'forge-std/Script.sol';
import {AaveV3Ethereum} from 'aave-address-book/AaveV3Ethereum.sol';
import {AaveV3Optimism} from 'aave-address-book/AaveV3Optimism.sol';
import {AaveV3Arbitrum} from 'aave-address-book/AaveV3Arbitrum.sol';
import {AaveV3Polygon} from 'aave-address-book/AaveV3Polygon.sol';
import {AaveV3Avalanche} from 'aave-address-book/AaveV3Avalanche.sol';
import {AaveV3ConfigEngine} from '../src/v3-config-engine/AaveV3ConfigEngine.sol';

/**
 * Helper contract to enforce correct chain selection in scripts
 */
abstract contract WithChainIdValidation is Script {
  constructor(uint256 chainId) {
    require(block.chainid == chainId, 'CHAIN_ID_MISMATCH');
  }
}

abstract contract EthereumScript is WithChainIdValidation {
  constructor() WithChainIdValidation(1) {}
}

abstract contract OptimismScript is WithChainIdValidation {
  constructor() WithChainIdValidation(10) {}
}

abstract contract ArbitrumScript is WithChainIdValidation {
  constructor() WithChainIdValidation(42161) {}
}

abstract contract PolygonScript is WithChainIdValidation {
  constructor() WithChainIdValidation(137) {}
}

abstract contract AvalancheScript is WithChainIdValidation {
  constructor() WithChainIdValidation(43114) {}
}

contract DeployEngineEth is EthereumScript {
  function run() external {
    vm.startBroadcast();
    new AaveV3ConfigEngine(
      AaveV3Ethereum.POOL,
      AaveV3Ethereum.POOL_CONFIGURATOR,
      AaveV3Ethereum.ORACLE,
      AaveV3Ethereum.DEFAULT_A_TOKEN_IMPL_REV_1,
      AaveV3Ethereum.DEFAULT_VARIABLE_DEBT_TOKEN_IMPL_REV_1,
      AaveV3Ethereum.DEFAULT_STABLE_DEBT_TOKEN_IMPL_REV_1,
      AaveV3Ethereum.DEFAULT_INCENTIVES_CONTROLLER,
      AaveV3Ethereum.COLLECTOR
    );
    vm.stopBroadcast();
  }
}

contract DeployEngineOpt is OptimismScript {
  function run() external {
    vm.startBroadcast();
    new AaveV3ConfigEngine(
      AaveV3Optimism.POOL,
      AaveV3Optimism.POOL_CONFIGURATOR,
      AaveV3Optimism.ORACLE,
      AaveV3Optimism.DEFAULT_A_TOKEN_IMPL_REV_1,
      AaveV3Optimism.DEFAULT_VARIABLE_DEBT_TOKEN_IMPL_REV_1,
      AaveV3Optimism.DEFAULT_STABLE_DEBT_TOKEN_IMPL_REV_1,
      AaveV3Optimism.DEFAULT_INCENTIVES_CONTROLLER,
      AaveV3Optimism.COLLECTOR
    );
    vm.stopBroadcast();
  }
}

contract DeployEngineArb is ArbitrumScript {
  function run() external {
    vm.startBroadcast();
    new AaveV3ConfigEngine(
      AaveV3Arbitrum.POOL,
      AaveV3Arbitrum.POOL_CONFIGURATOR,
      AaveV3Arbitrum.ORACLE,
      AaveV3Arbitrum.DEFAULT_A_TOKEN_IMPL_REV_1,
      AaveV3Arbitrum.DEFAULT_VARIABLE_DEBT_TOKEN_IMPL_REV_1,
      AaveV3Arbitrum.DEFAULT_STABLE_DEBT_TOKEN_IMPL_REV_1,
      AaveV3Arbitrum.DEFAULT_INCENTIVES_CONTROLLER,
      AaveV3Arbitrum.COLLECTOR
    );
    vm.stopBroadcast();
  }
}

contract DeployEnginePol is PolygonScript {
  function run() external {
    vm.startBroadcast();
    new AaveV3ConfigEngine(
      AaveV3Polygon.POOL,
      AaveV3Polygon.POOL_CONFIGURATOR,
      AaveV3Polygon.ORACLE,
      AaveV3Polygon.DEFAULT_A_TOKEN_IMPL_REV_1,
      AaveV3Polygon.DEFAULT_VARIABLE_DEBT_TOKEN_IMPL_REV_1,
      AaveV3Polygon.DEFAULT_STABLE_DEBT_TOKEN_IMPL_REV_1,
      AaveV3Polygon.DEFAULT_INCENTIVES_CONTROLLER,
      AaveV3Polygon.COLLECTOR
    );
    vm.stopBroadcast();
  }
}

contract DeployEngineAva is AvalancheScript {
  function run() external {
    vm.startBroadcast();
    new AaveV3ConfigEngine(
      AaveV3Avalanche.POOL,
      AaveV3Avalanche.POOL_CONFIGURATOR,
      AaveV3Avalanche.ORACLE,
      AaveV3Avalanche.DEFAULT_A_TOKEN_IMPL_REV_1,
      AaveV3Avalanche.DEFAULT_VARIABLE_DEBT_TOKEN_IMPL_REV_1,
      AaveV3Avalanche.DEFAULT_STABLE_DEBT_TOKEN_IMPL_REV_1,
      AaveV3Avalanche.DEFAULT_INCENTIVES_CONTROLLER,
      AaveV3Avalanche.COLLECTOR
    );
    vm.stopBroadcast();
  }
}
