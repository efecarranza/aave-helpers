// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3ConfigEngine} from '../src/v3-config-engine/AaveV3ConfigEngine.sol';
import {IV3RateStrategyFactory} from '../src/v3-config-engine/IV3RateStrategyFactory.sol';
import './Utils.s.sol';

library DeployEngineEthLib {
  function deploy(address ratesFactory) internal returns (address) {
    require(ratesFactory != address(0), 'INVALID_RATES_FACTORY');

    return
      address(
        new AaveV3ConfigEngine(
          AaveV3Ethereum.POOL,
          AaveV3Ethereum.POOL_CONFIGURATOR,
          AaveV3Ethereum.ORACLE,
          AaveV3Ethereum.DEFAULT_A_TOKEN_IMPL_REV_1,
          AaveV3Ethereum.DEFAULT_VARIABLE_DEBT_TOKEN_IMPL_REV_1,
          AaveV3Ethereum.DEFAULT_STABLE_DEBT_TOKEN_IMPL_REV_1,
          AaveV3Ethereum.DEFAULT_INCENTIVES_CONTROLLER,
          AaveV3Ethereum.COLLECTOR,
          IV3RateStrategyFactory(ratesFactory)
        )
      );
  }
}

library DeployEngineOptLib {
  function deploy(address ratesFactory) internal returns (address) {
    require(ratesFactory != address(0), 'INVALID_RATES_FACTORY');

    return
      address(
        new AaveV3ConfigEngine(
          AaveV3Optimism.POOL,
          AaveV3Optimism.POOL_CONFIGURATOR,
          AaveV3Optimism.ORACLE,
          AaveV3Optimism.DEFAULT_A_TOKEN_IMPL_REV_1,
          AaveV3Optimism.DEFAULT_VARIABLE_DEBT_TOKEN_IMPL_REV_1,
          AaveV3Optimism.DEFAULT_STABLE_DEBT_TOKEN_IMPL_REV_1,
          AaveV3Optimism.DEFAULT_INCENTIVES_CONTROLLER,
          AaveV3Optimism.COLLECTOR,
          IV3RateStrategyFactory(ratesFactory)
        )
      );
  }
}

library DeployEngineArbLib {
  function deploy(address ratesFactory) internal returns (address) {
    require(ratesFactory != address(0), 'INVALID_RATES_FACTORY');

    return
      address(
        new AaveV3ConfigEngine(
          AaveV3Arbitrum.POOL,
          AaveV3Arbitrum.POOL_CONFIGURATOR,
          AaveV3Arbitrum.ORACLE,
          AaveV3Arbitrum.DEFAULT_A_TOKEN_IMPL_REV_1,
          AaveV3Arbitrum.DEFAULT_VARIABLE_DEBT_TOKEN_IMPL_REV_1,
          AaveV3Arbitrum.DEFAULT_STABLE_DEBT_TOKEN_IMPL_REV_1,
          AaveV3Arbitrum.DEFAULT_INCENTIVES_CONTROLLER,
          AaveV3Arbitrum.COLLECTOR,
          IV3RateStrategyFactory(ratesFactory)
        )
      );
  }
}

library DeployEnginePolLib {
  function deploy(address ratesFactory) internal returns (address) {
    require(ratesFactory != address(0), 'INVALID_RATES_FACTORY');

    return
      address(
        new AaveV3ConfigEngine(
          AaveV3Polygon.POOL,
          AaveV3Polygon.POOL_CONFIGURATOR,
          AaveV3Polygon.ORACLE,
          AaveV3Polygon.DEFAULT_A_TOKEN_IMPL_REV_1,
          AaveV3Polygon.DEFAULT_VARIABLE_DEBT_TOKEN_IMPL_REV_1,
          AaveV3Polygon.DEFAULT_STABLE_DEBT_TOKEN_IMPL_REV_1,
          AaveV3Polygon.DEFAULT_INCENTIVES_CONTROLLER,
          AaveV3Polygon.COLLECTOR,
          IV3RateStrategyFactory(ratesFactory)
        )
      );
  }
}

library DeployEngineAvaLib {
  function deploy(address ratesFactory) internal returns (address) {
    require(ratesFactory != address(0), 'INVALID_RATES_FACTORY');

    return
      address(
        new AaveV3ConfigEngine(
          AaveV3Avalanche.POOL,
          AaveV3Avalanche.POOL_CONFIGURATOR,
          AaveV3Avalanche.ORACLE,
          AaveV3Avalanche.DEFAULT_A_TOKEN_IMPL_REV_1,
          AaveV3Avalanche.DEFAULT_VARIABLE_DEBT_TOKEN_IMPL_REV_1,
          AaveV3Avalanche.DEFAULT_STABLE_DEBT_TOKEN_IMPL_REV_1,
          AaveV3Avalanche.DEFAULT_INCENTIVES_CONTROLLER,
          AaveV3Avalanche.COLLECTOR,
          IV3RateStrategyFactory(ratesFactory)
        )
      );
  }
}

contract DeployEngineEth is EthereumScript {
  function run() external broadcast {
    DeployEngineEthLib.deploy(address(0)); // TODO
  }
}

contract DeployEngineOpt is OptimismScript {
  function run() external {
    DeployEngineOptLib.deploy(address(0)); // TODO
  }
}

contract DeployEngineArb is ArbitrumScript {
  function run() external {
    DeployEngineArbLib.deploy(address(0)); // TODO
  }
}

contract DeployEnginePol is PolygonScript {
  function run() external {
    DeployEnginePolLib.deploy(address(0)); // TODO
  }
}

contract DeployEngineAva is AvalancheScript {
  function run() external {
    DeployEngineAvaLib.deploy(address(0)); // TODO
  }
}
