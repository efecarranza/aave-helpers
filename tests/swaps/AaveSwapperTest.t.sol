// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Test} from 'forge-std/Test.sol';
import {GovernanceV3Ethereum} from 'aave-address-book/GovernanceV3Ethereum.sol';
import {AaveV2Ethereum, AaveV2EthereumAssets} from 'aave-address-book/AaveV2Ethereum.sol';
import {AaveV3Ethereum, AaveV3EthereumAssets} from 'aave-address-book/AaveV3Ethereum.sol';
import {IERC20} from 'solidity-utils/contracts/oz-common/interfaces/IERC20.sol';

import {IAggregatorV3Interface} from '../../src/swaps/interfaces/IAggregatorV3Interface.sol';
import {AaveSwapper} from '../../src/swaps/AaveSwapper.sol';
import {IAaveSwapper} from '../../src/swaps/IAaveSwapper.sol';

contract MockOracle {
  fallback() external {} // Nothing Happens
}

contract AaveSwapperTest is Test {
  event DepositedIntoV2(address indexed token, uint256 amount);
  event DepositedIntoV3(address indexed token, uint256 amount);
  event GuardianUpdated(address oldGuardian, address newGuardian);
  event LimitSwapRequested(
    address milkman,
    address indexed fromToken,
    address indexed toToken,
    uint256 amount,
    address indexed recipient,
    uint256 minAmountOut
  );
  event SwapCanceled(address indexed fromToken, address indexed toToken, uint256 amount);
  event SwapRequested(
    address milkman,
    address indexed fromToken,
    address indexed toToken,
    address fromOracle,
    address toOracle,
    uint256 amount,
    address indexed recipient,
    uint256 slippage
  );
  event TokenUpdated(address indexed token, bool allowed);

  address public constant BAL80WETH20 = 0x5c6Ee304399DBdB9C8Ef030aB642B10820DB8F56;
  address public constant BPT_PRICE_CHECKER = 0xBeA6AAC5bDCe0206A9f909d80a467C93A7D6Da7c;
  address public constant CHAINLINK_PRICE_CHECKER = 0xe80a1C615F75AFF7Ed8F08c9F21f9d00982D666c;
  address public constant LIMIT_ORDER_PRICE_CHECKER = 0xcfb9Bc9d2FA5D3Dd831304A0AE53C76ed5c64802;
  address public constant MILKMAN = 0x11C76AD590ABDFFCD980afEC9ad951B160F02797;
  address public constant BAD_ORACLE = 0x05225Cd708bCa9253789C1374e4337a019e99D56;

  AaveSwapper public swaps;

  function setUp() public virtual {
    vm.createSelectFork(vm.rpcUrl('mainnet'), 17779177);

    vm.startPrank(GovernanceV3Ethereum.EXECUTOR_LVL_1);
    swaps = new AaveSwapper();
    vm.stopPrank();
  }
}

contract Initialize is AaveSwapperTest {
  function test_revertsIf_alreadyInitialized() public {
    vm.expectRevert('Initializable: contract is already initialized');
    swaps.initialize();
  }
}

contract TransferOwnership is AaveSwapperTest {
  function test_revertsIf_invalidCaller() public {
    vm.expectRevert('Ownable: caller is not the owner');
    swaps.transferOwnership(makeAddr('new-admin'));
  }

  function test_successful() public {
    address newAdmin = makeAddr('new-admin');
    vm.startPrank(GovernanceV3Ethereum.EXECUTOR_LVL_1);
    swaps.transferOwnership(newAdmin);
    vm.stopPrank();

    assertEq(newAdmin, swaps.owner());
  }
}

contract UpdateGuardian is AaveSwapperTest {
  function test_revertsIf_invalidCaller() public {
    vm.expectRevert('ONLY_BY_OWNER_OR_GUARDIAN');
    swaps.updateGuardian(makeAddr('new-admin'));
  }

  function test_successful() public {
    address newManager = makeAddr('new-admin');
    vm.expectEmit();
    emit GuardianUpdated(swaps.guardian(), newManager);
    vm.startPrank(GovernanceV3Ethereum.EXECUTOR_LVL_1);
    swaps.updateGuardian(newManager);
    vm.stopPrank();

    assertEq(newManager, swaps.guardian());
  }
}

contract RemoveGuardian is AaveSwapperTest {
  function test_revertsIf_invalidCaller() public {
    vm.expectRevert('ONLY_BY_OWNER_OR_GUARDIAN');
    swaps.updateGuardian(address(0));
  }

  function test_successful() public {
    vm.expectEmit();
    emit GuardianUpdated(swaps.guardian(), address(0));
    vm.startPrank(GovernanceV3Ethereum.EXECUTOR_LVL_1);
    swaps.updateGuardian(address(0));
    vm.stopPrank();

    assertEq(address(0), swaps.guardian());
  }
}

contract AaveSwapperSwap is AaveSwapperTest {
  function test_revertsIf_invalidCaller() public {
    uint256 amount = 1_000e18;
    vm.expectRevert('Ownable: caller is not the owner');
    swaps.swap(
      MILKMAN,
      CHAINLINK_PRICE_CHECKER,
      AaveV2EthereumAssets.WETH_UNDERLYING,
      AaveV2EthereumAssets.AAVE_UNDERLYING,
      AaveV2EthereumAssets.WETH_ORACLE,
      AaveV2EthereumAssets.AAVE_ORACLE,
      address(AaveV2Ethereum.COLLECTOR),
      amount,
      200
    );
  }

  function test_revertsIf_amountIsZero() public {
    vm.startPrank(GovernanceV3Ethereum.EXECUTOR_LVL_1);
    vm.expectRevert(IAaveSwapper.InvalidAmount.selector);
    swaps.swap(
      MILKMAN,
      CHAINLINK_PRICE_CHECKER,
      AaveV3EthereumAssets.WETH_UNDERLYING,
      AaveV3EthereumAssets.AAVE_UNDERLYING,
      AaveV3EthereumAssets.WETH_ORACLE,
      AaveV3EthereumAssets.AAVE_ORACLE,
      address(AaveV2Ethereum.COLLECTOR),
      0,
      200
    );
    vm.stopPrank();
  }

  function test_revertsIf_fromTokenIsZeroAddress() public {
    vm.startPrank(GovernanceV3Ethereum.EXECUTOR_LVL_1);
    vm.expectRevert(IAaveSwapper.Invalid0xAddress.selector);
    swaps.swap(
      MILKMAN,
      CHAINLINK_PRICE_CHECKER,
      address(0),
      AaveV3EthereumAssets.AAVE_UNDERLYING,
      AaveV3EthereumAssets.WETH_ORACLE,
      AaveV3EthereumAssets.AAVE_ORACLE,
      address(AaveV2Ethereum.COLLECTOR),
      1_000e18,
      200
    );
    vm.stopPrank();
  }

  function test_revertsIf_toTokenIsZeroAddress() public {
    vm.startPrank(GovernanceV3Ethereum.EXECUTOR_LVL_1);
    vm.expectRevert(IAaveSwapper.Invalid0xAddress.selector);
    swaps.swap(
      MILKMAN,
      CHAINLINK_PRICE_CHECKER,
      AaveV3EthereumAssets.WETH_UNDERLYING,
      address(0),
      AaveV3EthereumAssets.WETH_ORACLE,
      AaveV3EthereumAssets.AAVE_ORACLE,
      address(AaveV2Ethereum.COLLECTOR),
      1_000e18,
      200
    );
    vm.stopPrank();
  }

  function test_revertsIf_invalidRecipient() public {
    vm.startPrank(GovernanceV3Ethereum.EXECUTOR_LVL_1);
    vm.expectRevert(IAaveSwapper.InvalidRecipient.selector);
    swaps.swap(
      MILKMAN,
      CHAINLINK_PRICE_CHECKER,
      AaveV2EthereumAssets.AAVE_UNDERLYING,
      AaveV2EthereumAssets.USDC_UNDERLYING,
      AaveV2EthereumAssets.AAVE_ORACLE,
      AaveV2EthereumAssets.USDC_ORACLE,
      address(0),
      1_000e18,
      200
    );
    vm.stopPrank();
  }

  function test_revertsIf_fromOracleNotSet() public {
    vm.startPrank(GovernanceV3Ethereum.EXECUTOR_LVL_1);
    vm.expectRevert(IAaveSwapper.OracleNotSet.selector);
    swaps.swap(
      MILKMAN,
      CHAINLINK_PRICE_CHECKER,
      AaveV2EthereumAssets.AAVE_UNDERLYING,
      AaveV2EthereumAssets.USDC_UNDERLYING,
      address(0),
      AaveV2EthereumAssets.USDC_ORACLE,
      address(AaveV3Ethereum.COLLECTOR),
      1_000e18,
      200
    );
    vm.stopPrank();
  }

  function test_revertsIf_toOracleNotSet() public {
    vm.startPrank(GovernanceV3Ethereum.EXECUTOR_LVL_1);
    vm.expectRevert(IAaveSwapper.OracleNotSet.selector);
    swaps.swap(
      MILKMAN,
      CHAINLINK_PRICE_CHECKER,
      AaveV2EthereumAssets.AAVE_UNDERLYING,
      AaveV2EthereumAssets.USDC_UNDERLYING,
      AaveV2EthereumAssets.AAVE_ORACLE,
      address(0),
      address(AaveV3Ethereum.COLLECTOR),
      1_000e18,
      200
    );
    vm.stopPrank();
  }

  function test_revertsIf_fromOracleIsInvalidNoDecimalsFunction() public {
    vm.startPrank(GovernanceV3Ethereum.EXECUTOR_LVL_1);
    vm.expectRevert();
    swaps.swap(
      MILKMAN,
      CHAINLINK_PRICE_CHECKER,
      AaveV2EthereumAssets.AAVE_UNDERLYING,
      AaveV2EthereumAssets.USDC_UNDERLYING,
      BAD_ORACLE,
      AaveV2EthereumAssets.USDC_ORACLE,
      address(AaveV3Ethereum.COLLECTOR),
      1_000e18,
      200
    );
    vm.stopPrank();
  }

  function test_revertsIf_toOracleIsInvalidNoDecimalsFunction() public {
    vm.startPrank(GovernanceV3Ethereum.EXECUTOR_LVL_1);
    vm.expectRevert();
    swaps.swap(
      MILKMAN,
      CHAINLINK_PRICE_CHECKER,
      AaveV2EthereumAssets.AAVE_UNDERLYING,
      AaveV2EthereumAssets.USDC_UNDERLYING,
      AaveV2EthereumAssets.AAVE_ORACLE,
      BAD_ORACLE,
      address(AaveV3Ethereum.COLLECTOR),
      1_000e18,
      200
    );
    vm.stopPrank();
  }

  function test_revertsIf_fromOracleIsInvalid() public {
    vm.startPrank(GovernanceV3Ethereum.EXECUTOR_LVL_1);
    vm.expectRevert(IAaveSwapper.InvalidOracle.selector);
    vm.mockCall(
      BAD_ORACLE,
      abi.encodeWithSelector(IAggregatorV3Interface.decimals.selector),
      abi.encode(uint8(0))
    );
    swaps.swap(
      MILKMAN,
      CHAINLINK_PRICE_CHECKER,
      AaveV2EthereumAssets.AAVE_UNDERLYING,
      AaveV2EthereumAssets.USDC_UNDERLYING,
      BAD_ORACLE,
      AaveV2EthereumAssets.USDC_ORACLE,
      address(AaveV3Ethereum.COLLECTOR),
      1_000e18,
      200
    );
    vm.stopPrank();
  }

  function test_revertsIf_fromOracleIsInvalidWithFallbackFunction() public {
    address badOracle = address(new MockOracle());

    vm.startPrank(GovernanceV3Ethereum.EXECUTOR_LVL_1);
    vm.expectRevert();
    swaps.swap(
      MILKMAN,
      CHAINLINK_PRICE_CHECKER,
      AaveV2EthereumAssets.AAVE_UNDERLYING,
      AaveV2EthereumAssets.USDC_UNDERLYING,
      badOracle,
      AaveV2EthereumAssets.USDC_ORACLE,
      address(AaveV3Ethereum.COLLECTOR),
      1_000e18,
      200
    );
    vm.stopPrank();
  }

  function test_revertsIf_passedOracleIsAaveV2WETHOracle() public {
    vm.startPrank(GovernanceV3Ethereum.EXECUTOR_LVL_1);
    vm.expectRevert(IAaveSwapper.OracleNotSet.selector);
    swaps.swap(
      MILKMAN,
      CHAINLINK_PRICE_CHECKER,
      AaveV2EthereumAssets.WETH_UNDERLYING,
      AaveV2EthereumAssets.USDC_UNDERLYING,
      AaveV2EthereumAssets.WETH_ORACLE,
      AaveV2EthereumAssets.USDC_ORACLE,
      address(0),
      1_000e18,
      200
    );
    vm.stopPrank();
  }

  function test_successful() public {
    deal(AaveV2EthereumAssets.AAVE_UNDERLYING, address(swaps), 1_000e18);
    vm.startPrank(GovernanceV3Ethereum.EXECUTOR_LVL_1);

    vm.expectEmit(true, true, true, true);
    emit SwapRequested(
      MILKMAN,
      AaveV2EthereumAssets.AAVE_UNDERLYING,
      AaveV2EthereumAssets.USDC_UNDERLYING,
      AaveV2EthereumAssets.AAVE_ORACLE,
      AaveV2EthereumAssets.USDC_ORACLE,
      1_000e18,
      address(AaveV2Ethereum.COLLECTOR),
      200
    );
    swaps.swap(
      MILKMAN,
      CHAINLINK_PRICE_CHECKER,
      AaveV2EthereumAssets.AAVE_UNDERLYING,
      AaveV2EthereumAssets.USDC_UNDERLYING,
      AaveV2EthereumAssets.AAVE_ORACLE,
      AaveV2EthereumAssets.USDC_ORACLE,
      address(AaveV2Ethereum.COLLECTOR),
      1_000e18,
      200
    );
    vm.stopPrank();
  }
}

contract CancelSwap is AaveSwapperTest {
  function test_revertsIf_invalidCaller() public {
    uint256 amount = 1_000e18;
    vm.expectRevert('ONLY_BY_OWNER_OR_GUARDIAN');
    swaps.cancelSwap(
      makeAddr('milkman-instance'),
      CHAINLINK_PRICE_CHECKER,
      AaveV2EthereumAssets.WETH_UNDERLYING,
      AaveV2EthereumAssets.AAVE_UNDERLYING,
      AaveV2EthereumAssets.WETH_ORACLE,
      AaveV2EthereumAssets.AAVE_ORACLE,
      address(AaveV2Ethereum.COLLECTOR),
      amount,
      200
    );
  }

  function test_revertsIf_noMatchingTrade() public {
    deal(AaveV2EthereumAssets.AAVE_UNDERLYING, address(swaps), 1_000e18);
    vm.startPrank(GovernanceV3Ethereum.EXECUTOR_LVL_1);
    swaps.swap(
      MILKMAN,
      CHAINLINK_PRICE_CHECKER,
      AaveV2EthereumAssets.AAVE_UNDERLYING,
      AaveV2EthereumAssets.USDC_UNDERLYING,
      AaveV2EthereumAssets.AAVE_ORACLE,
      AaveV2EthereumAssets.USDC_ORACLE,
      address(AaveV2Ethereum.COLLECTOR),
      1_000e18,
      200
    );

    vm.expectRevert();
    swaps.cancelSwap(
      makeAddr('not-milkman-instance'),
      CHAINLINK_PRICE_CHECKER,
      AaveV2EthereumAssets.AAVE_UNDERLYING,
      AaveV2EthereumAssets.USDC_UNDERLYING,
      AaveV2EthereumAssets.AAVE_ORACLE,
      AaveV2EthereumAssets.USDC_ORACLE,
      address(AaveV2Ethereum.COLLECTOR),
      1_000e18,
      200
    );
    vm.stopPrank();
  }

  function test_successful() public {
    deal(AaveV2EthereumAssets.AAVE_UNDERLYING, address(swaps), 1_000e18);
    vm.startPrank(GovernanceV3Ethereum.EXECUTOR_LVL_1);

    vm.expectEmit(true, true, true, true);
    emit SwapRequested(
      MILKMAN,
      AaveV2EthereumAssets.AAVE_UNDERLYING,
      AaveV2EthereumAssets.USDC_UNDERLYING,
      AaveV2EthereumAssets.AAVE_ORACLE,
      AaveV2EthereumAssets.USDC_ORACLE,
      1_000e18,
      address(AaveV2Ethereum.COLLECTOR),
      200
    );
    swaps.swap(
      MILKMAN,
      CHAINLINK_PRICE_CHECKER,
      AaveV2EthereumAssets.AAVE_UNDERLYING,
      AaveV2EthereumAssets.USDC_UNDERLYING,
      AaveV2EthereumAssets.AAVE_ORACLE,
      AaveV2EthereumAssets.USDC_ORACLE,
      address(AaveV2Ethereum.COLLECTOR),
      1_000e18,
      200
    );

    vm.expectEmit();
    emit SwapCanceled(
      AaveV2EthereumAssets.AAVE_UNDERLYING,
      AaveV2EthereumAssets.USDC_UNDERLYING,
      1_000e18
    );
    swaps.cancelSwap(
      0xd0B587b7712a495499d45F761e234839d7E8D026, // Address generated by tests
      CHAINLINK_PRICE_CHECKER,
      AaveV2EthereumAssets.AAVE_UNDERLYING,
      AaveV2EthereumAssets.USDC_UNDERLYING,
      AaveV2EthereumAssets.AAVE_ORACLE,
      AaveV2EthereumAssets.USDC_ORACLE,
      address(AaveV2Ethereum.COLLECTOR),
      1_000e18,
      200
    );
    vm.stopPrank();
  }
}

contract EmergencyTokenTransfer is AaveSwapperTest {
  function test_revertsIf_invalidCaller() public {
    vm.expectRevert('ONLY_RESCUE_GUARDIAN');
    swaps.emergencyTokenTransfer(
      AaveV2EthereumAssets.BAL_UNDERLYING,
      address(AaveV2Ethereum.COLLECTOR),
      1_000e6
    );
  }

  function test_successful_governanceCaller() public {
    address AAVE_WHALE = 0xBE0eB53F46cd790Cd13851d5EFf43D12404d33E8;

    assertEq(IERC20(AaveV2EthereumAssets.AAVE_UNDERLYING).balanceOf(address(swaps)), 0);

    uint256 aaveAmount = 1_000e18;

    vm.startPrank(AAVE_WHALE);
    IERC20(AaveV2EthereumAssets.AAVE_UNDERLYING).transfer(address(swaps), aaveAmount);
    vm.stopPrank();

    assertEq(IERC20(AaveV2EthereumAssets.AAVE_UNDERLYING).balanceOf(address(swaps)), aaveAmount);

    uint256 initialCollectorUsdcBalance = IERC20(AaveV2EthereumAssets.AAVE_UNDERLYING).balanceOf(
      address(AaveV2Ethereum.COLLECTOR)
    );

    vm.startPrank(GovernanceV3Ethereum.EXECUTOR_LVL_1);
    swaps.emergencyTokenTransfer(
      AaveV2EthereumAssets.AAVE_UNDERLYING,
      address(AaveV2Ethereum.COLLECTOR),
      aaveAmount
    );
    vm.stopPrank();

    assertEq(
      IERC20(AaveV2EthereumAssets.AAVE_UNDERLYING).balanceOf(address(AaveV2Ethereum.COLLECTOR)),
      initialCollectorUsdcBalance + aaveAmount
    );
    assertEq(IERC20(AaveV2EthereumAssets.AAVE_UNDERLYING).balanceOf(address(swaps)), 0);
  }
}

contract GetExpectedOut is AaveSwapperTest {
  function test_revertsIf_fromOracleIsAddressZero() public {
    uint256 amount = 1e18;
    vm.expectRevert(IAaveSwapper.OracleNotSet.selector);
    swaps.getExpectedOut(
      CHAINLINK_PRICE_CHECKER,
      amount,
      AaveV2EthereumAssets.AAVE_UNDERLYING,
      AaveV2EthereumAssets.USDC_UNDERLYING,
      address(0),
      AaveV2EthereumAssets.USDC_ORACLE
    );
  }

  function test_revertsIf_toOracleIsAddressZero() public {
    uint256 amount = 1e18;
    vm.expectRevert(IAaveSwapper.OracleNotSet.selector);
    swaps.getExpectedOut(
      CHAINLINK_PRICE_CHECKER,
      amount,
      AaveV2EthereumAssets.AAVE_UNDERLYING,
      AaveV2EthereumAssets.USDC_UNDERLYING,
      AaveV2EthereumAssets.AAVE_ORACLE,
      address(0)
    );
  }

  function test_aaveToUsdc_withEthBasedOracles() public {
    /* This test is only to show that oracles with the same base
     * will return the correct value for trading, or at least very
     * close to USD based oracles. Nonetheless, ETH based oracles
     * should not be used. Please ensure only USD based oracles are
     * set for trading.
     * Using different bases in a swap can lead to destructive results.
     */
    uint256 amount = 1e18;
    uint256 expected = swaps.getExpectedOut(
      CHAINLINK_PRICE_CHECKER,
      amount,
      AaveV2EthereumAssets.AAVE_UNDERLYING,
      AaveV2EthereumAssets.USDC_UNDERLYING,
      AaveV2EthereumAssets.AAVE_ORACLE,
      AaveV2EthereumAssets.USDC_ORACLE
    );

    // July 26, 2023 2:55PM EST AAVE/USD is around $71.20
    assertEq(expected / 1e4, 7121); // USDC is 6 decimals
  }

  function test_aaveToUsdc() public {
    uint256 amount = 1e18;
    uint256 expected = swaps.getExpectedOut(
      CHAINLINK_PRICE_CHECKER,
      amount,
      AaveV3EthereumAssets.AAVE_UNDERLYING,
      AaveV3EthereumAssets.USDC_UNDERLYING,
      AaveV3EthereumAssets.AAVE_ORACLE,
      AaveV3EthereumAssets.USDC_ORACLE
    );

    // July 26, 2023 2:55PM EST AAVE/USD is around $71.20
    assertEq(expected / 1e4, 7167); // USDC is 6 decimals
  }

  function test_ethToDai() public {
    uint256 amount = 1e18;
    uint256 expected = swaps.getExpectedOut(
      CHAINLINK_PRICE_CHECKER,
      amount,
      AaveV3EthereumAssets.WETH_UNDERLYING,
      AaveV3EthereumAssets.DAI_UNDERLYING,
      AaveV3EthereumAssets.WETH_ORACLE,
      AaveV3EthereumAssets.DAI_ORACLE
    );

    // July 26, 2023 2:55PM EST ETH/USD is around $1,870
    assertEq(expected / 1e18, 1870); // WETH is 18 decimals
  }

  function test_ethToBal() public {
    uint256 amount = 1e18;
    uint256 expected = swaps.getExpectedOut(
      CHAINLINK_PRICE_CHECKER,
      amount,
      AaveV3EthereumAssets.WETH_UNDERLYING,
      AaveV3EthereumAssets.BAL_UNDERLYING,
      AaveV3EthereumAssets.WETH_ORACLE,
      AaveV3EthereumAssets.BAL_ORACLE
    );

    // July 26, 2023 2:55PM EST ETH/USD is around $1,870, BAL/USD $4.50
    // Thus, ETH/BAL should be around 415 BAL tokens
    assertEq(expected / 1e18, 415); // WETH and BAL are 18 decimals
  }

  function test_balTo80BAL20WETH() public {
    uint256 amount = 100e18;
    uint256 expected = swaps.getExpectedOut(
      BPT_PRICE_CHECKER,
      amount,
      AaveV3EthereumAssets.BAL_UNDERLYING,
      BAL80WETH20,
      address(0),
      address(0)
    );

    // July 25, 2023 10:15AM EST BAL/USD is around $4.50 B-80BAL-20WETH $12.50
    // Thus, BAL/BPT should be around 0.35 at 100 units traded, 35 units expected.
    assertEq(expected / 1e18, 35); // WETH and BAL are 18 decimals
  }
}

contract LimitSwap is AaveSwapperTest {
  function setUp() public override {
    vm.createSelectFork(vm.rpcUrl('mainnet'), 18815161);

    vm.startPrank(GovernanceV3Ethereum.EXECUTOR_LVL_1);
    swaps = new AaveSwapper();
    vm.stopPrank();
  }

  function test_revertsIf_invalidCaller() public {
    uint256 amount = 1_000e18;
    vm.expectRevert('Ownable: caller is not the owner');
    swaps.limitSwap(
      MILKMAN,
      LIMIT_ORDER_PRICE_CHECKER,
      AaveV2EthereumAssets.WETH_UNDERLYING,
      AaveV2EthereumAssets.AAVE_UNDERLYING,
      address(AaveV2Ethereum.COLLECTOR),
      amount,
      1_000e18
    );
  }

  function test_revertsIf_amountIsZero() public {
    vm.startPrank(GovernanceV3Ethereum.EXECUTOR_LVL_1);
    vm.expectRevert(IAaveSwapper.InvalidAmount.selector);
    swaps.limitSwap(
      MILKMAN,
      LIMIT_ORDER_PRICE_CHECKER,
      AaveV2EthereumAssets.WETH_UNDERLYING,
      AaveV2EthereumAssets.AAVE_UNDERLYING,
      address(AaveV2Ethereum.COLLECTOR),
      0,
      1_000e18
    );
    vm.stopPrank();
  }

  function test_revertsIf_fromTokenIsZeroAddress() public {
    vm.startPrank(GovernanceV3Ethereum.EXECUTOR_LVL_1);
    vm.expectRevert(IAaveSwapper.Invalid0xAddress.selector);
    swaps.limitSwap(
      MILKMAN,
      LIMIT_ORDER_PRICE_CHECKER,
      address(0),
      AaveV3EthereumAssets.AAVE_UNDERLYING,
      address(AaveV2Ethereum.COLLECTOR),
      1_000e18,
      1_000e18
    );
    vm.stopPrank();
  }

  function test_revertsIf_toTokenIsZeroAddress() public {
    vm.startPrank(GovernanceV3Ethereum.EXECUTOR_LVL_1);
    vm.expectRevert(IAaveSwapper.Invalid0xAddress.selector);
    swaps.limitSwap(
      MILKMAN,
      LIMIT_ORDER_PRICE_CHECKER,
      AaveV3EthereumAssets.WETH_UNDERLYING,
      address(0),
      address(AaveV2Ethereum.COLLECTOR),
      1_000e18,
      1_000e18
    );
    vm.stopPrank();
  }

  function test_revertsIf_invalidRecipient() public {
    vm.startPrank(GovernanceV3Ethereum.EXECUTOR_LVL_1);
    vm.expectRevert(IAaveSwapper.InvalidRecipient.selector);
    swaps.limitSwap(
      MILKMAN,
      LIMIT_ORDER_PRICE_CHECKER,
      AaveV2EthereumAssets.AAVE_UNDERLYING,
      AaveV2EthereumAssets.USDC_UNDERLYING,
      address(0),
      1_000e18,
      1_000e18
    );
    vm.stopPrank();
  }

  function test_successful() public {
    deal(AaveV2EthereumAssets.AAVE_UNDERLYING, address(swaps), 1_000e18);
    vm.startPrank(GovernanceV3Ethereum.EXECUTOR_LVL_1);

    vm.expectEmit(true, true, true, true);
    emit LimitSwapRequested(
      MILKMAN,
      AaveV2EthereumAssets.AAVE_UNDERLYING,
      AaveV2EthereumAssets.USDC_UNDERLYING,
      1_000e18,
      address(AaveV2Ethereum.COLLECTOR),
      1_000e18
    );
    swaps.limitSwap(
      MILKMAN,
      LIMIT_ORDER_PRICE_CHECKER,
      AaveV2EthereumAssets.AAVE_UNDERLYING,
      AaveV2EthereumAssets.USDC_UNDERLYING,
      address(AaveV2Ethereum.COLLECTOR),
      1_000e18,
      1_000e18
    );
    vm.stopPrank();
  }
}

contract CancelLimitSwap is AaveSwapperTest {
  function setUp() public override {
    vm.createSelectFork(vm.rpcUrl('mainnet'), 18815161);

    vm.startPrank(GovernanceV3Ethereum.EXECUTOR_LVL_1);
    swaps = new AaveSwapper();
    vm.stopPrank();
  }

  function test_revertsIf_invalidCaller() public {
    uint256 amount = 1_000e18;
    vm.expectRevert('ONLY_BY_OWNER_OR_GUARDIAN');
    swaps.cancelLimitSwap(
      makeAddr('milkman-instance'),
      LIMIT_ORDER_PRICE_CHECKER,
      AaveV2EthereumAssets.WETH_UNDERLYING,
      AaveV2EthereumAssets.AAVE_UNDERLYING,
      address(AaveV2Ethereum.COLLECTOR),
      amount,
      amount
    );
  }

  function test_revertsIf_noMatchingTrade() public {
    deal(AaveV2EthereumAssets.AAVE_UNDERLYING, address(swaps), 1_000e18);
    vm.startPrank(GovernanceV3Ethereum.EXECUTOR_LVL_1);
    swaps.limitSwap(
      MILKMAN,
      LIMIT_ORDER_PRICE_CHECKER,
      AaveV2EthereumAssets.AAVE_UNDERLYING,
      AaveV2EthereumAssets.USDC_UNDERLYING,
      address(AaveV2Ethereum.COLLECTOR),
      1_000e18,
      1_000e18
    );

    vm.expectRevert();
    swaps.cancelLimitSwap(
      makeAddr('not-milkman-instance'),
      LIMIT_ORDER_PRICE_CHECKER,
      AaveV2EthereumAssets.AAVE_UNDERLYING,
      AaveV2EthereumAssets.USDC_UNDERLYING,
      address(AaveV2Ethereum.COLLECTOR),
      1_000e18,
      1_000e18
    );
    vm.stopPrank();
  }

  function test_successful() public {
    deal(AaveV2EthereumAssets.AAVE_UNDERLYING, address(swaps), 1_000e18);
    vm.startPrank(GovernanceV3Ethereum.EXECUTOR_LVL_1);

    vm.expectEmit(true, true, true, true);
    emit LimitSwapRequested(
      MILKMAN,
      AaveV2EthereumAssets.AAVE_UNDERLYING,
      AaveV2EthereumAssets.USDC_UNDERLYING,
      1_000e18,
      address(AaveV2Ethereum.COLLECTOR),
      1_000e18
    );
    swaps.limitSwap(
      MILKMAN,
      LIMIT_ORDER_PRICE_CHECKER,
      AaveV2EthereumAssets.AAVE_UNDERLYING,
      AaveV2EthereumAssets.USDC_UNDERLYING,
      address(AaveV2Ethereum.COLLECTOR),
      1_000e18,
      1_000e18
    );

    vm.expectEmit();
    emit SwapCanceled(
      AaveV2EthereumAssets.AAVE_UNDERLYING,
      AaveV2EthereumAssets.USDC_UNDERLYING,
      1_000e18
    );
    swaps.cancelLimitSwap(
      0x524c7Dfc9fEd2C68fAcBfA2aBF8aD58fd6fdb408, // Address generated by tests
      LIMIT_ORDER_PRICE_CHECKER,
      AaveV2EthereumAssets.AAVE_UNDERLYING,
      AaveV2EthereumAssets.USDC_UNDERLYING,
      address(AaveV2Ethereum.COLLECTOR),
      1_000e18,
      1_000e18
    );
    vm.stopPrank();
  }
}
