// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from 'solidity-utils/contracts/oz-common/interfaces/IERC20.sol';
import {SafeERC20} from 'solidity-utils/contracts/oz-common/SafeERC20.sol';
import {OwnableWithGuardian} from 'solidity-utils/contracts/access-control/OwnableWithGuardian.sol';
import {CollectorUtils, ICollector} from './CollectorUtils.sol';
import {AaveV3Ethereum, AaveV3EthereumAssets} from 'aave-address-book/AaveV3Ethereum.sol';
import {AaveV2Ethereum, AaveV2EthereumAssets} from 'aave-address-book/AaveV2Ethereum.sol';
import {MiscEthereum} from 'aave-address-book/MiscEthereum.sol';
import {IPool, DataTypes as DataTypesV3} from 'aave-address-book/AaveV3.sol';
import {ILendingPool, DataTypes as DataTypesV2} from 'aave-address-book/AaveV2.sol';
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
  using CollectorUtils for ICollector;
  using DataTypesV2 for DataTypesV2.ReserveData;
  using DataTypesV3 for DataTypesV3.ReserveData;

  ILendingPool immutable POOLV2 = AaveV2Ethereum.POOL;
  IPool immutable POOLV3 = AaveV3Ethereum.POOL;
  ICollector immutable collector = AaveV3Ethereum.COLLECTOR;

  AaveSwapper public immutable SWAPPER = AaveSwapper(MiscEthereum.AAVE_SWAPPER);
  address public immutable MILKMAN = 0x11C76AD590ABDFFCD980afEC9ad951B160F02797;
  address public immutable PRICE_CHECKER = 0xe80a1C615F75AFF7Ed8F08c9F21f9d00982D666c;

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
    collector.transfer(reserve, address(this), amount);
    IERC20(reserve).approve(address(POOLV3), amount);
    POOLV3.deposit(reserve, amount, address(collector), 0);
  }

  /// @inheritdoc IFinanceSteward
  function migrateV2toV3(address reserve, uint amount) external onlyOwnerOrGuardian {
    require(amount > 0, 'Submit positive amount');
    DataTypesV2.ReserveData memory reserveData = POOLV2.getReserveData(reserve);

    address atoken = reserveData.aTokenAddress;
    if (minTokenBalance[atoken] > 0) {
      uint currentBalance = IERC20(atoken).balanceOf(address(collector));
      require(currentBalance - amount > minTokenBalance[atoken], 'MINIMUM BALANCE SHIELDED');
    }

    collector.transfer(atoken, address(this), amount);
    uint256 widrAmount = POOLV2.withdraw(reserve, amount, address(this));

    IERC20(reserve).approve(address(POOLV3), widrAmount);
    POOLV3.deposit(reserve, widrAmount, address(collector), 0);
  }

  /// @inheritdoc IFinanceSteward
  function withdrawV2andSwap(
    address reserve,
    uint amount,
    address buyToken
  ) external onlyOwnerOrGuardian {
    _validateSwap(reserve, amount, buyToken);

    DataTypesV2.ReserveData memory reserveData = POOLV2.getReserveData(reserve);

    address atoken = reserveData.aTokenAddress;
    if (minTokenBalance[atoken] > 0) {
      uint currentBalance = IERC20(atoken).balanceOf(address(collector));
      require(currentBalance - amount > minTokenBalance[atoken], 'MINIMUM BALANCE SHIELDED');
    }

    collector.transfer(atoken, address(this), amount);
    uint256 widrAmount = POOLV2.withdraw(reserve, amount, address(SWAPPER));

    AaveV3Ethereum.COLLECTOR.swapWithBalance(
      SWAPPER,
      CollectorUtils.SwapInput({
        milkman: MILKMAN,
        priceChecker: PRICE_CHECKER,
        fromUnderlying: reserve,
        toUnderlying: buyToken,
        fromUnderlyingPriceFeed: priceOracle[reserve],
        toUnderlyingPriceFeed: priceOracle[buyToken],
        amount: widrAmount,
        slippage: 1_50
      })
    );
  }

  /// @inheritdoc IFinanceSteward
  function withdrawV3andSwap(
    address reserve,
    uint amount,
    address buyToken
  ) external onlyOwnerOrGuardian {
    _validateSwap(reserve, amount, buyToken);

    DataTypesV3.ReserveData memory reserveData = POOLV3.getReserveData(reserve);
    address atoken = reserveData.aTokenAddress;
    if (minTokenBalance[atoken] > 0) {
      uint currentBalance = IERC20(atoken).balanceOf(address(collector));
      require(currentBalance - amount > minTokenBalance[atoken], 'MINIMUM BALANCE SHIELDED');
    }

    collector.transfer(atoken, address(this), amount);
    uint256 widrAmount = POOLV3.withdraw(reserve, amount, address(SWAPPER));

    AaveV3Ethereum.COLLECTOR.swapWithBalance(
      SWAPPER,
      CollectorUtils.SwapInput({
        milkman: MILKMAN,
        priceChecker: PRICE_CHECKER,
        fromUnderlying: reserve,
        toUnderlying: buyToken,
        fromUnderlyingPriceFeed: priceOracle[reserve],
        toUnderlyingPriceFeed: priceOracle[buyToken],
        amount: widrAmount,
        slippage: 1_50
      })
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
    
    AaveV3Ethereum.COLLECTOR.swap(
      SWAPPER,
      CollectorUtils.SwapInput({
        milkman: MILKMAN,
        priceChecker: PRICE_CHECKER,
        fromUnderlying: sellToken,
        toUnderlying: buyToken,
        fromUnderlyingPriceFeed: priceOracle[sellToken],
        toUnderlyingPriceFeed: priceOracle[buyToken],
        amount: amount,
        slippage: 1_50
      })
    );
  }

  // Controlled Actions

  /// @inheritdoc IFinanceSteward
  function approve(address token, address to, uint256 amount) external onlyOwnerOrGuardian {
    _validateTransfer(token, to, amount);
    collector.approve(token, to, amount);
  }

  /// @inheritdoc IFinanceSteward
  function transfer(address token, address to, uint256 amount) external onlyOwnerOrGuardian {
    _validateTransfer(token, to, amount);
    collector.transfer(token, to, amount);
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
