// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {IERC20} from 'solidity-utils/contracts/oz-common/interfaces/IERC20.sol';
import {SafeERC20} from 'solidity-utils/contracts/oz-common/SafeERC20.sol';
import {Ownable} from 'solidity-utils/contracts/oz-common/Ownable.sol';
import {Rescuable} from 'solidity-utils/contracts/utils/Rescuable.sol';
import {AaveV3Ethereum} from 'aave-address-book/AaveV3Ethereum.sol';
import {AaveV2Polygon} from 'aave-address-book/AaveV2Polygon.sol';

import {ChainIds} from '../ChainIds.sol';
import {IAavePolEthERC20Bridge} from './IAavePolEthERC20Bridge.sol';

interface IRootChainManager {
  function exit(bytes calldata inputData) external;
}

interface IERC20Polygon {
  function balanceOf(address account) external view returns (uint256);

  function transfer(address to, uint256 amount) external returns (bool);

  function withdraw(uint256 amount) external;
}

/**
 * @title AavePolEthERC20Bridge
 * @author Llama
 * @notice Helper contract to bridge assets from polygon to ethereum
 */
contract AavePolEthERC20Bridge is Ownable, Rescuable, IAavePolEthERC20Bridge {
  using SafeERC20 for IERC20;

  error InvalidChain();

  event Exit();
  event Bridge(address token, uint256 amount);
  event WithdrawToCollector(address token, uint256 amount);

  address public constant ROOT_CHAIN_MANAGER = 0xA0c68C638235ee32657e8f720a23ceC1bFc77C77;

  constructor(address _owner) {
    _transferOwnership(_owner);
  }

  /// @inheritdoc IAavePolEthERC20Bridge
  function bridge(address token, uint256 amount) external onlyOwner {
    if (block.chainid != ChainIds.POLYGON) revert InvalidChain();

    IERC20Polygon(token).withdraw(amount);
    emit Bridge(token, amount);
  }

  /// @inheritdoc IAavePolEthERC20Bridge
  function exit(bytes calldata burnProof) external {
    if (block.chainid != ChainIds.MAINNET) revert InvalidChain();

    IRootChainManager(ROOT_CHAIN_MANAGER).exit(burnProof);
    emit Exit();
  }

  /// @inheritdoc IAavePolEthERC20Bridge
  function withdrawToCollector(address token) external {
    if (block.chainid != ChainIds.MAINNET) revert InvalidChain();

    uint256 balance = IERC20(token).balanceOf(address(this));

    IERC20(token).safeTransfer(address(AaveV3Ethereum.COLLECTOR), balance);
    emit WithdrawToCollector(token, balance);
  }

  /// @inheritdoc Rescuable
  function whoCanRescue() public view override returns (address) {
    return owner();
  }
}
