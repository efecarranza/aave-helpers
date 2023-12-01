// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ArbitrumScript, EthereumScript, PolygonScript} from 'src/ScriptUtils.sol';
import {GovernanceV3Ethereum} from 'aave-address-book/GovernanceV3Ethereum.sol';
import {GovernanceV3Polygon} from 'aave-address-book/GovernanceV3Polygon.sol';

import {AavePolEthERC20Bridge} from 'src/bridges/AavePolEthERC20Bridge.sol';
import {AaveArbEthERC20Bridge} from 'src/bridges/arbitrum/AaveArbEthERC20Bridge.sol';

import {AaveV3ArbitrumAssets} from 'aave-address-book/AaveV3Arbitrum.sol';
import {AaveV3EthereumAssets} from 'aave-address-book/AaveV3Ethereum.sol';
import {IERC20} from 'solidity-utils/contracts/oz-common/interfaces/IERC20.sol';

contract DeployEthereum is EthereumScript {
  function run() external broadcast {
    bytes32 salt = 'Aave Treasury Bridge';
    new AavePolEthERC20Bridge{salt: salt}(GovernanceV3Ethereum.EXECUTOR_LVL_1);
  }
}

contract DeployPolygon is PolygonScript {
  function run() external broadcast {
    bytes32 salt = 'Aave Treasury Bridge';
    new AavePolEthERC20Bridge{salt: salt}(GovernanceV3Polygon.EXECUTOR_LVL_1);
  }
}

contract DeployArbitrum is ArbitrumScript {
  function run() external broadcast {
    bytes32 salt = 'Aave Treasury Bridge';
    new AaveArbEthERC20Bridge{salt: salt}(0x3765A685a401622C060E5D700D9ad89413363a91);
  }
}

contract TestArbitrumBridge is ArbitrumScript {
  address public constant LINK_GATEWAY = 0x09e9222E96E7B4AE2a407B98d48e330053351EEe;

  function run() external broadcast {
    address bridge = 0x0e6bB71856C5c821d1B83F2C6a9A59A78d5e0712;
    uint256 amount = IERC20(AaveV3ArbitrumAssets.LINK_UNDERLYING).balanceOf(
      0x3765A685a401622C060E5D700D9ad89413363a91
    );

    IERC20(AaveV3ArbitrumAssets.LINK_UNDERLYING).transfer(bridge, amount);

    AaveArbEthERC20Bridge(bridge).bridge(
      AaveV3ArbitrumAssets.LINK_UNDERLYING,
      AaveV3EthereumAssets.LINK_UNDERLYING,
      LINK_GATEWAY,
      amount
    );
  }
}
