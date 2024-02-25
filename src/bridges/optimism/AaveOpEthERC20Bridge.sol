// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {IERC20} from 'solidity-utils/contracts/oz-common/interfaces/IERC20.sol';
import {SafeERC20} from 'solidity-utils/contracts/oz-common/SafeERC20.sol';
import {Ownable} from 'solidity-utils/contracts/oz-common/Ownable.sol';
import {Rescuable} from 'solidity-utils/contracts/utils/Rescuable.sol';
import {AaveV3Ethereum} from 'aave-address-book/AaveV3Ethereum.sol';

import {ChainIds} from '../../ChainIds.sol';
import {IAaveOpEthERC20Bridge} from './IAaveOpEthERC20Bridge.sol';

/**
 * @title AaveOpEthERC20Bridge
 * @author efecarranza.eth
 * @notice Helper contract to bridge assets from Optimism to Ethereum Mainnet
 */
contract AaveOpEthERC20Bridge is Ownable, Rescuable, IAaveOpEthERC20Bridge {
  using SafeERC20 for IERC20;

    address public constant L1_STANDARD_BRIDGE = 0x99C9fc46f92E8a1c0deC1b1747d010903E884bE1;
  address public constant L2_STANDARD_BRIDGE = 0x4200000000000000000000000000000000000010;

  /// @param _owner The owner of the contract upon deployment
  constructor(address _owner) {
    _transferOwnership(_owner);
  }

  function bridge() external onlyOwner {
    if (block.chainid != ChainIds.OPTIMISM) revert InvalidChain();
  }

  function confirmBridge() external {
    if (block.chainid != ChainIds.OPTIMISM) revert InvalidChain();
  }

  function exit() external {
    if (block.chainid != ChainIds.MAINNET) revert InvalidChain();
  }

  /// @inheritdoc Rescuable
  function whoCanRescue() public view override returns (address) {
    return owner();
  }
}
