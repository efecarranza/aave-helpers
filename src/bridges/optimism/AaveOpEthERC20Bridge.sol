// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {IERC20} from 'solidity-utils/contracts/oz-common/interfaces/IERC20.sol';
import {SafeERC20} from 'solidity-utils/contracts/oz-common/SafeERC20.sol';
import {Ownable} from 'solidity-utils/contracts/oz-common/Ownable.sol';
import {Rescuable} from 'solidity-utils/contracts/utils/Rescuable.sol';
import {AaveV3Ethereum} from 'aave-address-book/AaveV3Ethereum.sol';

import {ChainIds} from '../../ChainIds.sol';
import {IAaveOpEthERC20Bridge} from './IAaveOpEthERC20Bridge.sol';

contract AaveOpEthERC20Bridge is Ownable, Rescuable, IAaveOpEthERC20Bridge {
    function whoCanRescue() public view override returns (address) {
    return owner();
  }
}
