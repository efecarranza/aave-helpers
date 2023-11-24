// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import {IERC20} from 'solidity-utils/contracts/oz-common/interfaces/IERC20.sol';

import {EthereumScript} from 'src/ScriptUtils.sol';
import {AaveSwapper} from 'src/swaps/AaveSwapper.sol';

// make test-swap
contract TestSwap is EthereumScript {
    uint256 public constant AMOUNT = 0;
    uint256 public constant SLIPPAGE = 0; // In BPS (basis points, ie: 100 is 1%)

    address public constant SWAPPER_INSTANCE = address(0); // Your deployed swapper instance
    address public constant MILKMAN = address(0); // Milkman instance: 0x11C76AD590ABDFFCD980afEC9ad951B160F02797
    address public constant PRICE_CHECKER = address(0); // Chainlink Price Checker: 0xe80a1C615F75AFF7Ed8F08c9F21f9d00982D666c

    address public constant FROM_TOKEN = address(0);
    address public constant TO_TOKEN = address(0);
    address public constant FROM_ORACLE = address(0);
    address public constant TO_ORACLE = address(0);

    
    function run() external broadcast {
        IERC20(FROM_TOKEN).approve(SWAPPER_INSTANCE, AMOUNT);

        AaveSwapper(SWAPPER_INSTANCE).swap(
            MILKMAN,
            PRICE_CHECKER,
            FROM_TOKEN,
            TO_TOKEN,
            FROM_ORACLE,
            TO_ORACLE,
            msg.sender,
            AMOUNT,
            SLIPPAGE
        );
    }
}

// make cancel-swap
contract CancelSwap is EthereumScript {
    uint256 public constant AMOUNT = 0;
    uint256 public constant SLIPPAGE = 0; // In BPS (basis points, ie: 100 is 1%)

    address public constant SWAPPER_INSTANCE = address(0); // Your deployed swapper instance
    address public constant TRADE_MILKMAN = address(0); // Contract that received funds after swap
    address public constant PRICE_CHECKER = address(0); // 

    address public constant FROM_TOKEN = address(0);
    address public constant TO_TOKEN = address(0);
    address public constant FROM_ORACLE = address(0);
    address public constant TO_ORACLE = address(0);

    function run() external broadcast {
        AaveSwapper(SWAPPER_INSTANCE).cancelSwap(
            TRADE_MILKMAN,
            PRICE_CHECKER,
            FROM_TOKEN,
            TO_TOKEN,
            FROM_ORACLE,
            TO_ORACLE,
            msg.sender,
            AMOUNT,
            SLIPPAGE
        );
    }
}
