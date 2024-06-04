// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {IERC20} from 'solidity-utils/contracts/oz-common/interfaces/IERC20.sol';
import {GovernanceV3Ethereum} from 'aave-address-book/GovernanceV3Ethereum.sol';
import {GovernanceV3Polygon} from 'aave-address-book/GovernanceV3Polygon.sol';
import {GovernanceV3Arbitrum} from 'aave-address-book/GovernanceV3Arbitrum.sol';

import {AaveV3Arbitrum, AaveV3ArbitrumAssets} from 'aave-address-book/AaveV3Arbitrum.sol';
import {AaveV3Ethereum, AaveV3EthereumAssets} from 'aave-address-book/AaveV3Ethereum.sol';

import {ArbitrumScript, EthereumScript, PolygonScript} from 'src/ScriptUtils.sol';
import {AaveArbEthERC20Bridge} from 'src/bridges/arbitrum/AaveArbEthERC20Bridge.sol';
import {AavePolEthERC20Bridge} from 'src/bridges/polygon/AavePolEthERC20Bridge.sol';
import {AavePolEthPlasmaBridge} from 'src/bridges/polygon/AavePolEthPlasmaBridge.sol';

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

contract DeployPlasmaEthereum is EthereumScript {
  function run() external broadcast {
    bytes32 salt = 'Aave Treasury Plasma Bridge';
    new AavePolEthPlasmaBridge{salt: salt}(0x3765A685a401622C060E5D700D9ad89413363a91);
  }
}

contract DeployPlasmaPolygon is PolygonScript {
  function run() external broadcast {
    bytes32 salt = 'Aave Treasury Plasma Bridge';
    new AavePolEthPlasmaBridge{salt: salt}(0x3765A685a401622C060E5D700D9ad89413363a91);
  }
}

contract DeployArbBridgeEthereum is EthereumScript {
  function run() external broadcast {
    bytes32 salt = 'Aave Treasury Bridge';
    new AaveArbEthERC20Bridge{salt: salt}(0x3765A685a401622C060E5D700D9ad89413363a91);
  }
}

contract DeployArbBridgeArbitrum is ArbitrumScript {
  function run() external broadcast {
    bytes32 salt = 'Aave Treasury Bridge';
    new AaveArbEthERC20Bridge{salt: salt}(0x3765A685a401622C060E5D700D9ad89413363a91);
  }
}

contract ExitTokens is EthereumScript {
  function run() external broadcast {
    bytes32[] memory proof = new bytes32[](17);

    proof[0] = 0x77c057b2c96b4fe0cd5777c5a0f27e3ba91933e165e330bdbeaad37db0c76438;
    proof[1] = 0xe5dd5e7a38177afc450aafa87ca1ca74eca01de5d11bba1b9f342ba99e14f0c5;
    proof[2] = 0x1560170349b9c31a186a462900ba1b01912565e470b29601c27bbcab706c075f;
    proof[3] = 0x23a00efa913aba6608c1ecb86ca1b5d151bc5b2dd870e69f77028fc97b2ebcf1;
    proof[4] = 0xad79a95bb1e589b26080c5ea8fed5bc60bdd1da5daa08986614dffce91c9bc58;
    proof[5] = 0x68b5102cfaff7a3dc08ad61010d6730b8ea5730f9a12c473bd34da3abcfa75d9;
    proof[6] = 0xbab5252a9d414b66c923e9ac0bcf5c77406cfa94d0560318f0a65dbd351e3462;
    proof[7] = 0x17fa29748e4c7a6b2a3a68bd850038d943ee36e008aef6f035d46702dd2fd79a;
    proof[8] = 0xd76638cb083cfd92b14234158590478a3d820d44fcb24ddc0f5c73204cdbd36a;
    proof[9] = 0xb78836417db2b95712fffdae66bb58290186b707a1a2f1b6e4b5d6163b9a8e73;
    proof[10] = 0x4adbf54066119b6881337087c52a766969473c99ce6f3a6014b86508e9f1be12;
    proof[11] = 0xf7a9c5c62750d0d2489e1a4efffa5122bcb800e6e9032ed442e5987e18ceecd6;
    proof[12] = 0x412b066c3e520231f300ca6cc974f08ed77b7d39532029e79f9c47cf2b7242df;
    proof[13] = 0x0000000000000000000000000000000000000000000000000000000000000000;
    proof[14] = 0xe293e3dc5befe34c72d718dc7b2e5f5cfdeb11a8c3387f0811a76c1d8825903c;
    proof[15] = 0xc0425084107ea9f7a4118f5ed1e3566cda4e90b550363fc804df1e52ed5f2386;
    proof[16] = 0xb43a6b28077d49f37d58c87aec0b51f7bce13b648143f3295385f3b3d5ac3b9b;

    bytes memory data = hex'2e567b36000000000000000000000000c02aaa39b223fe8d0a0e5c4f27ead9083c756cc20000000000000000000000000335ffa9af5ce05590d6c9a75b645470e07744a9000000000000000000000000464c71f6c2f760dda6093dcb91c24c39e5d6e18c00000000000000000000000000000000000000000000000000000000000003e800000000000000000000000000000000000000000000000000000000000000a0000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000002ae00000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000';

    AaveArbEthERC20Bridge(0x0335ffa9af5CE05590d6C9A75B645470e07744a9).exit(
      proof,
      118423,
      0x6c411aD3E74De3E7Bd422b94A27770f5B86C623B,
      0xd92023E9d9911199a6711321D1277285e6d4e2db,
      210534980,
      19854800,
      1715527345,
      1000,
      data
    );
  }
}
  
contract BridgeTokens is ArbitrumScript {
  address public constant DAI_GATEWAY = 0x467194771dAe2967Aef3ECbEDD3Bf9a310C76C65;
  address public constant USDC_NATIVE_GATEWAY = 0x096760F208390250649E3e8763348E783AEF5562 ;
  address public constant WBTC_GATEWAY = 0x09e9222E96E7B4AE2a407B98d48e330053351EEe;
  address public constant WETH_GATEWAY = 0x6c411aD3E74De3E7Bd422b94A27770f5B86C623B;
  address public constant USDT_GATEWAY = 0x096760F208390250649E3e8763348E783AEF5562;
  address public constant WSTETH_GATEWAY = 0x07D4692291B9E30E326fd31706f686f83f331B82;

  function run() external broadcast {
    // IERC20(AaveV3ArbitrumAssets.DAI_UNDERLYING).balanceOf(0x3765A685a401622C060E5D700D9ad89413363a91);
    // IERC20(AaveV3ArbitrumAssets.USDC_UNDERLYING).balanceOf(0x3765A685a401622C060E5D700D9ad89413363a91);
    // IERC20(AaveV3ArbitrumAssets.WBTC_UNDERLYING).balanceOf(0x3765A685a401622C060E5D700D9ad89413363a91);
    // IERC20(AaveV3ArbitrumAssets.WETH_UNDERLYING).balanceOf(0x3765A685a401622C060E5D700D9ad89413363a91);
    // IERC20(AaveV3ArbitrumAssets.USDT_UNDERLYING).balanceOf(0x3765A685a401622C060E5D700D9ad89413363a91);
    // IERC20(AaveV3ArbitrumAssets.wstETH_UNDERLYING).balanceOf(0x3765A685a401622C060E5D700D9ad89413363a91);

    // DAI
    // AaveArbEthERC20Bridge(0x0335ffa9af5CE05590d6C9A75B645470e07744a9).bridge(
    //   AaveV3ArbitrumAssets.DAI_UNDERLYING,
    //   AaveV3EthereumAssets.DAI_UNDERLYING,
    //   DAI_GATEWAY,
    //   IERC20(AaveV3ArbitrumAssets.DAI_UNDERLYING).balanceOf(0x3765A685a401622C060E5D700D9ad89413363a91)
    // );

    // USDC
    // AaveArbEthERC20Bridge(0x0335ffa9af5CE05590d6C9A75B645470e07744a9).bridge(
    //   AaveV3ArbitrumAssets.USDC_UNDERLYING,
    //   AaveV3EthereumAssets.USDC_UNDERLYING,
    //   USDC_NATIVE_GATEWAY,
    //   1
    // );

    // WBTC
    // AaveArbEthERC20Bridge(0x0335ffa9af5CE05590d6C9A75B645470e07744a9).bridge(
    //   AaveV3ArbitrumAssets.WBTC_UNDERLYING,
    //   AaveV3EthereumAssets.WBTC_UNDERLYING,
    //   WBTC_GATEWAY,
    //   IERC20(AaveV3ArbitrumAssets.WBTC_UNDERLYING).balanceOf(0x0335ffa9af5CE05590d6C9A75B645470e07744a9)
    // );

    // // WETH_A_TOKEN
    // AaveArbEthERC20Bridge(0x0335ffa9af5CE05590d6C9A75B645470e07744a9).bridge(
    //   AaveV3ArbitrumAssets.WETH_UNDERLYING,
    //   AaveV3EthereumAssets.WETH_UNDERLYING,
    //   WETH_GATEWAY,
    //   IERC20(AaveV3ArbitrumAssets.WETH_UNDERLYING).balanceOf(0x3765A685a401622C060E5D700D9ad89413363a91)
    // );
    
    // // USDT
    // AaveArbEthERC20Bridge(0x0335ffa9af5CE05590d6C9A75B645470e07744a9).bridge(
    //   AaveV3ArbitrumAssets.USDT_UNDERLYING,
    //   AaveV3EthereumAssets.USDT_UNDERLYING,
    //   USDT_GATEWAY,
    //   IERC20(AaveV3ArbitrumAssets.USDT_UNDERLYING).balanceOf(0x3765A685a401622C060E5D700D9ad89413363a91)
    // );

    // wstETH
    AaveArbEthERC20Bridge(0x0335ffa9af5CE05590d6C9A75B645470e07744a9).bridge(
      AaveV3ArbitrumAssets.wstETH_UNDERLYING,
      AaveV3EthereumAssets.wstETH_UNDERLYING,
      WSTETH_GATEWAY,
      IERC20(AaveV3ArbitrumAssets.wstETH_UNDERLYING).balanceOf(0x3765A685a401622C060E5D700D9ad89413363a91)
    );
  }
}
