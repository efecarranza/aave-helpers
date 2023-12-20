// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Script} from 'forge-std/Script.sol';
import {MiscEthereum} from 'aave-address-book/MiscEthereum.sol';

import {AaveSwapper} from 'src/swaps/AaveSwapper.sol';

import {IPriceChecker} from './interfaces/IExpectedOutCalculator.sol';
import {IMilkman} from './interfaces/IMilkman.sol';
import {IERC20} from 'solidity-utils/contracts/oz-common/interfaces/IERC20.sol';
import {SafeERC20} from 'solidity-utils/contracts/oz-common/SafeERC20.sol';

contract TestLimitSwap is Script {
  using SafeERC20 for IERC20;

  address public constant milkman = 0x11C76AD590ABDFFCD980afEC9ad951B160F02797;
  address public constant priceChecker = 0xcfb9Bc9d2FA5D3Dd831304A0AE53C76ed5c64802;
  address public constant fromToken = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // wETH
  address public constant toToken = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48; // USDC
  address public constant recipient = 0x3765A685a401622C060E5D700D9ad89413363a91; // me
  uint256 public constant amount = 18019075246814393;
  uint256 public constant amountOut = 17000000;

  function run() external {
    vm.startBroadcast();

    IERC20(fromToken).forceApprove(milkman, amount);

    IMilkman(milkman).requestSwapExactTokensForTokens(
      amount,
      IERC20(fromToken),
      IERC20(toToken),
      recipient,
      priceChecker,
      abi.encode(amountOut)
    );

    // IMilkman(tradeMilkman).cancelSwap(
    //   amount,
    //   IERC20(fromToken),
    //   IERC20(toToken),
    //   recipient,
    //   priceChecker,
    //   abi.encode(amountOut)
    // );

    vm.stopBroadcast();
  }
}
