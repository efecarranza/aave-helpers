// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from 'solidity-utils/contracts/oz-common/interfaces/IERC20.sol';
import {SafeERC20} from 'solidity-utils/contracts/oz-common/SafeERC20.sol';
import {OwnableWithGuardian} from 'solidity-utils/contracts/access-control/OwnableWithGuardian.sol';
import {DataTypes} from './DataTypes.sol';
import {ICollector} from './ICollector.sol';
import {IPool2, IPool3} from './ILendingPool.sol';
import {AaveSwapper} from '../swaps/AaveSwapper.sol';
import {AggregatorInterface} from './AggregatorInterface.sol';
import {IFinanceSteward} from './IFinanceSteward.sol';

/**
 * @title FinanceSteward
 * @author luigy-lemon  (Karpatkey)
 * @author efecarranza  (Tokenlogic)
 * @notice Helper contract that enables a Guardian to execute permissioned actions on the Aave Collector
 */
contract FinanceSteward is OwnableWithGuardian, IFinanceSteward {
  IPool2 POOLV2 = IPool2(0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9);
  IPool3 POOLV3 = IPool3(0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2);
  ICollector collector = ICollector(0x464C71f6c2F760DdA6093dCB91C24c39e5d6e18c);

  AaveSwapper public constant SWAPPER = AaveSwapper(0x3ea64b1C0194524b48F9118462C8E9cd61a243c7);
  address public constant MILKMAN = 0x11C76AD590ABDFFCD980afEC9ad951B160F02797;
  address public constant PRICE_CHECKER = 0xe80a1C615F75AFF7Ed8F08c9F21f9d00982D666c;

  mapping(address => bool) public transferApprovedReceiver;
  mapping(address => bool) public swapApprovedToken;
  mapping(address => address) public priceOracle;
  mapping(address => uint) public tokenBudget;
  mapping(address => uint) public minTokenBalance;

  constructor(address _owner, address _guardian) {
    _transferOwnership(_owner);
    _updateGuardian(_guardian);
  }

  /// Steward Actions

  /// @inheritdoc IFinanceSteward
  function depositV3(address reserve, uint amount) external onlyOwnerOrGuardian {
    collector.transfer(IERC20(reserve), address(this), amount);
    IERC20(reserve).approve(address(POOLV3), amount);
    POOLV3.deposit(reserve, amount, address(collector), 0);
  }

  /// @inheritdoc IFinanceSteward
  function migrateV2toV3(address reserve, uint amount) external onlyOwnerOrGuardian {
    require(amount > 0, 'Submit positive amount');
    DataTypes.ReserveDataV2 memory reserveData = POOLV2.getReserveData(reserve);

    address atoken = reserveData.aTokenAddress;
    if (minTokenBalance[atoken] > 0) {
      uint currentBalance = IERC20(atoken).balanceOf(address(collector));
      require(currentBalance - amount > minTokenBalance[atoken], 'MINIMUM BALANCE SHIELDED');
    }

    collector.transfer(IERC20(atoken), address(this), amount);
    POOLV2.withdraw(reserve, amount, address(this));

    uint balance = IERC20(reserve).balanceOf(address(this));
    IERC20(reserve).approve(address(POOLV3), balance);
    POOLV3.deposit(reserve, balance, address(collector), 0);
  }

  /// @inheritdoc IFinanceSteward
  function withdrawV2andSwap(
    address reserve,
    uint amount,
    address buyToken
  ) external onlyOwnerOrGuardian {
    _validateSwap(reserve, amount, buyToken);

    DataTypes.ReserveDataV2 memory reserveData = POOLV2.getReserveData(reserve);

    address atoken = reserveData.aTokenAddress;
    if (minTokenBalance[atoken] > 0) {
      uint currentBalance = IERC20(atoken).balanceOf(address(collector));
      require(currentBalance - amount > minTokenBalance[atoken], 'MINIMUM BALANCE SHIELDED');
    }

    uint swapperBalance = IERC20(reserve).balanceOf(address(SWAPPER));

    collector.transfer(IERC20(atoken), address(this), amount);
    POOLV2.withdraw(reserve, amount, address(SWAPPER));

    //Only swap amount withdrawn!
    uint swapAmount = IERC20(reserve).balanceOf(address(SWAPPER)) - swapperBalance;

    SWAPPER.swap(
      MILKMAN,
      PRICE_CHECKER,
      reserve,
      buyToken,
      priceOracle[reserve],
      priceOracle[buyToken],
      address(collector),
      swapAmount,
      100
    );
  }

  /// @inheritdoc IFinanceSteward
  function withdrawV3andSwap(
    address reserve,
    uint amount,
    address buyToken
  ) external onlyOwnerOrGuardian {
    _validateSwap(reserve, amount, buyToken);

    DataTypes.ReserveDataV3 memory reserveData = POOLV3.getReserveData(reserve);
    address atoken = reserveData.aTokenAddress;
    if (minTokenBalance[atoken] > 0) {
      uint currentBalance = IERC20(atoken).balanceOf(address(collector));
      require(currentBalance - amount > minTokenBalance[atoken], 'MINIMUM BALANCE SHIELDED');
    }

    uint swapperBalance = IERC20(reserve).balanceOf(address(SWAPPER));

    collector.transfer(IERC20(atoken), address(this), amount);
    POOLV3.withdraw(reserve, amount, address(SWAPPER));

    //Only swap amount withdrawn!
    uint swapAmount = IERC20(reserve).balanceOf(address(SWAPPER)) - swapperBalance;

    SWAPPER.swap(
      MILKMAN,
      PRICE_CHECKER,
      reserve,
      buyToken,
      priceOracle[reserve],
      priceOracle[buyToken],
      address(collector),
      swapAmount,
      100
    );
  }

  /// @inheritdoc IFinanceSteward
  function tokenSwap(
    address sellToken,
    uint256 amount,
    address buyToken
  ) external onlyOwnerOrGuardian {
    _validateSwap(sellToken, amount, buyToken);

    if (minTokenBalance[sellToken] > 0) {
      uint currentBalance = IERC20(sellToken).balanceOf(address(collector));
      require(currentBalance - amount > minTokenBalance[sellToken], 'MINIMUM BALANCE SHIELDED');
    }

    collector.transfer(IERC20(sellToken), address(SWAPPER), amount);

    SWAPPER.swap(
      MILKMAN,
      PRICE_CHECKER,
      sellToken,
      buyToken,
      priceOracle[sellToken],
      priceOracle[buyToken],
      address(collector),
      amount,
      100
    );
  }

  // Controlled Actions

  /// @inheritdoc IFinanceSteward
  function approve(address token, address to, uint256 amount) external onlyOwnerOrGuardian {
    _validateTransfer(token, to, amount);
    collector.approve(IERC20(token), to, amount);
  }

  /// @inheritdoc IFinanceSteward
  function transfer(address token, address to, uint256 amount) external onlyOwnerOrGuardian {
    _validateTransfer(token, to, amount);
    collector.transfer(IERC20(token), to, amount);
  }

  /// @inheritdoc IFinanceSteward
  function createStream(
    address token,
    address to,
    uint256 amount,
    uint256 duration
  ) external onlyOwnerOrGuardian {
    _validateTransfer(token, to, amount);
    require(duration < 999 days, 'DURATION TOO LONG');

    uint256 startTime = block.timestamp;
    uint256 stopTime = block.timestamp + duration;
    collector.createStream(to, amount, token, startTime, stopTime);
  }

  // Not sure if we want this functionality
  function cancelStream(uint256 streamId) external onlyOwnerOrGuardian {
    collector.cancelStream(streamId);
  }

  /// DAO Actions

  /// @inheritdoc IFinanceSteward
  function increaseBudget(address token, uint256 amount) external onlyOwner {
    uint currentBudget = tokenBudget[token];
    _updateBudget(token, currentBudget + amount);
  }

  /// @inheritdoc IFinanceSteward
  function decreaseBudget(address token, uint256 amount) external onlyOwner {
    uint currentBudget = tokenBudget[token];
    if (amount > currentBudget) {
      _updateBudget(token, 0);
    } else {
      _updateBudget(token, currentBudget - amount);
    }
  }

  /// @inheritdoc IFinanceSteward
  function setSwappableToken(address token, address priceFeedUSD) external onlyOwner {
    swapApprovedToken[token] = true;
    priceOracle[token] = priceFeedUSD;
    emit SwapApprovedToken(token, priceFeedUSD);
  }

  /// @inheritdoc IFinanceSteward
  function setWhitelistedReceiver(address to) external onlyOwner {
    transferApprovedReceiver[to] = true;
    emit ReceiverWhitelisted(to);
  }

  /// @inheritdoc IFinanceSteward
  function setMinimumBalanceShield(address token, uint amount) external onlyOwner {
    minTokenBalance[token] = amount;
    emit MinimumTokenBalanceUpdated(token, amount);
  }

  /// Logic

  function _validateTransfer(address token, address to, uint256 amount) internal {
    require(transferApprovedReceiver[to] == true, 'RECEIVER NOT WHITELISTED');

    if (minTokenBalance[token] > 0) {
      uint currentBalance = IERC20(token).balanceOf(address(collector));
      require(currentBalance - amount > minTokenBalance[token], 'MINIMUM BALANCE SHIELDED');
    }

    uint currentBudget = tokenBudget[token];
    require(currentBudget > amount, 'BUDGET BELOW TRANSFER AMOUNT');
    _updateBudget(token, currentBudget - amount);
  }

  function _validateSwap(address sellToken, uint amountIn, address buyToken) internal view {
    require(amountIn > 0, 'SUBMIT POSITIVE AMOUNT');
    require(swapApprovedToken[sellToken] && swapApprovedToken[buyToken], 'TOKEN NOT SWAP APPROVED');
    require(
      priceOracle[sellToken] > address(0) && priceOracle[buyToken] > address(0),
      'MISSING PRICE FEED'
    );
    require(
      AggregatorInterface(priceOracle[buyToken]).latestAnswer() > 0,
      'BuyToken: BAD PRICE FEED'
    );
    require(
      AggregatorInterface(priceOracle[sellToken]).latestAnswer() > 0,
      'SellToken: BAD PRICE FEED'
    );
  }

  function _updateBudget(address token, uint newAmount) internal {
    tokenBudget[token] = newAmount;
    emit BudgetUpdate(token, newAmount);
  }
}
