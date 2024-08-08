// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import {GovernanceV3Ethereum} from 'aave-address-book/GovernanceV3Ethereum.sol';
import {AaveV3Ethereum, AaveV3EthereumAssets} from 'aave-address-book/AaveV3Ethereum.sol';
import {FinanceSteward} from '../../src/financestewards/FinanceSteward.sol';
import {CollectorUtils} from '../../src/financestewards/CollectorUtils.sol';
import {IERC20} from 'solidity-utils/contracts/oz-common/interfaces/IERC20.sol';
import {ICollector} from 'aave-address-book/common/ICollector.sol';

/**
 * @dev Test for Finance Steward contract
 * command: make test contract-filter=FinanceSteward
 */

contract FinanceSteward_Test is Test {
  address public constant guardian = address(42);
  FinanceSteward public steward;

  address public alice = address(43);

  ICollector collector = AaveV3Ethereum.COLLECTOR;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'));
    steward = new FinanceSteward(
      GovernanceV3Ethereum.EXECUTOR_LVL_1,
      guardian
    );
    vm.prank(0x5300A1a15135EA4dc7aD5a167152C01EFc9b192A);
    collector.setFundsAdmin(address(steward));
    
  }
}

contract Function_depositV3 is FinanceSteward_Test {
  function test_revertsIf_notOwnerOrQuardian() public {
    vm.startPrank(alice);

    vm.expectRevert('ONLY_BY_OWNER_OR_GUARDIAN');
    steward.depositV3(AaveV3EthereumAssets.USDC_UNDERLYING, 1_000e6);
    vm.stopPrank();
  }

  function test_resvertsIf_zeroAmount() public {
    vm.startPrank(guardian);

    vm.expectRevert(CollectorUtils.InvalidZeroAmount.selector);
    steward.depositV3(AaveV3EthereumAssets.USDC_UNDERLYING, 0);
    vm.stopPrank();
  }

  function test_success() public {
    vm.startPrank(guardian);

    steward.depositV3(AaveV3EthereumAssets.USDC_UNDERLYING, 1_000e6);
    vm.stopPrank();
  }
}

contract Function_migrateV2toV3 is FinanceSteward_Test {
  function test_revertsIf_notOwnerOrQuardian() public {
    vm.startPrank(alice);

    vm.expectRevert('ONLY_BY_OWNER_OR_GUARDIAN');
    steward.migrateV2toV3(AaveV3EthereumAssets.USDC_UNDERLYING, 1_000e6);
    vm.stopPrank();
  }

  function test_resvertsIf_zeroAmount() public {
    vm.startPrank(guardian);

    vm.expectRevert(FinanceSteward.InvalidZeroAmount.selector);
    steward.migrateV2toV3(AaveV3EthereumAssets.USDC_UNDERLYING, 0);
    vm.stopPrank();
  }

  function test_resvertsIf_minimumBalanceShield() public {
    vm.startPrank(GovernanceV3Ethereum.EXECUTOR_LVL_1);
    steward.setMinimumBalanceShield(AaveV3EthereumAssets.USDC_UNDERLYING, 1_000e6);

    vm.startPrank(guardian);

    uint256 currentBalance = IERC20(AaveV3EthereumAssets.USDC_A_TOKEN).balanceOf(address(AaveV3Ethereum.COLLECTOR));

    vm.expectRevert(FinanceSteward.MinimumBalanceShield.selector);
    steward.migrateV2toV3(AaveV3EthereumAssets.USDC_UNDERLYING, currentBalance - 999e6);
    vm.stopPrank();
  }

  function test_success() public {
    vm.startPrank(guardian);

    steward.migrateV2toV3(AaveV3EthereumAssets.USDC_UNDERLYING, 1_000e6);
    vm.stopPrank();
  }
}