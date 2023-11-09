// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {IERC20} from 'solidity-utils/contracts/oz-common/interfaces/IERC20.sol';
import {SafeERC20} from 'solidity-utils/contracts/oz-common/SafeERC20.sol';
import {Ownable} from 'solidity-utils/contracts/oz-common/Ownable.sol';
import {Rescuable} from 'solidity-utils/contracts/utils/Rescuable.sol';
import {AaveV3Ethereum} from 'aave-address-book/AaveV3Ethereum.sol';

import {ChainIds} from '../../ChainIds.sol';
import {IAaveArbEthERC20Bridge} from './IAaveArbEthERC20Bridge.sol';

interface IL1Outbox {
  function executeTransaction(
    bytes32[] calldata proof,
    uint256 index,
    address l2sender,
    address to,
    uint256 l2block,
    uint256 l1block,
    uint256 l2timestamp,
    uint256 value,
    bytes calldata data
  ) external;
}

interface IL2Gateway {
  function outboundTransfer(
    address tokenAddress,
    address recipient,
    uint256 amount,
    bytes calldata data
  ) external;
}

contract AaveArbEthERC20Bridge is Ownable, Rescuable, IAaveArbEthERC20Bridge {
  using SafeERC20 for IERC20;

  error InvalidChain();

  event Bridge(address token, uint256 amount);
  event Exit();

  address public constant ARBITRUM_GATEWAY = 0x5288c571Fd7aD117beA99bF60FE0846C4E84F933;
  address public constant MAINNET_OUTBOX = 0x0B9857ae2D4A3DBe74ffE1d7DF045bb7F96E4840;

  /// @param _owner The owner of the contract upon deployment
  constructor(address _owner) {
    _transferOwnership(_owner);
  }

  /// @inheritdoc IAaveArbEthERC20Bridge
  function bridge(address token, address l1Token, uint256 amount) external onlyOwner {
    if (block.chainid != ChainIds.ARBITRUM) revert InvalidChain();

    IERC20(token).forceApprove(ARBITRUM_GATEWAY, amount);

    IL2Gateway(ARBITRUM_GATEWAY).outboundTransfer(
      l1Token,
      address(AaveV3Ethereum.COLLECTOR),
      amount,
      ''
    );
    emit Bridge(token, amount);
  }

  /// @inheritdoc IAaveArbEthERC20Bridge
  function exit(
    bytes32[] calldata proof,
    uint256 index,
    address l2sender,
    address to,
    uint256 l2block,
    uint256 l1block,
    uint256 l2timestamp,
    uint256 value,
    bytes calldata data
  ) external {
    if (block.chainid != ChainIds.MAINNET) revert InvalidChain();

    IL1Outbox(MAINNET_OUTBOX).executeTransaction(
      proof,
      index,
      l2sender,
      to,
      l2block,
      l1block,
      l2timestamp,
      value,
      data
    );
    emit Exit();
  }

  /// @inheritdoc Rescuable
  function whoCanRescue() public view override returns (address) {
    return owner();
  }
}
