// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from 'forge-std/Test.sol';
import {IERC20} from 'solidity-utils/contracts/oz-common/interfaces/IERC20.sol';
import {AaveV3Ethereum, AaveV3EthereumAssets} from 'aave-address-book/AaveV3Ethereum.sol';
import {AaveV3Arbitrum, AaveV3ArbitrumAssets} from 'aave-address-book/AaveV3Arbitrum.sol';
import {GovernanceV3Ethereum} from 'aave-address-book/GovernanceV3Ethereum.sol';
import {GovernanceV3Arbitrum} from 'aave-address-book/GovernanceV3Arbitrum.sol';

import {AaveArbEthERC20Bridge} from '../../src/bridges/arbitrum/AaveArbEthERC20Bridge.sol';

/**
 * @dev Tests for AaveArbEthERC20Bridge
 */
contract AaveArbEthERC20BridgeTest is Test {
  event Exit();
  event Bridge(address token, uint256 amount);

  AaveArbEthERC20Bridge bridgeMainnet;
  AaveArbEthERC20Bridge bridgeArbitrum;
  uint256 mainnetFork;
  uint256 arbitrumFork;

  address USDC_WHALE = 0x47c031236e19d024b42f8ae6780e44a573170703;
  address USDC_WHALE_MAINNET = 0xcEe284F754E854890e311e3280b767F80797180d;

  function setUp() public {
    bytes32 salt = keccak256(abi.encode(tx.origin, uint256(0)));

    mainnetFork = vm.createSelectFork(vm.rpcUrl('mainnet'), 18531022);
    bridgeMainnet = new AaveArbEthERC20Bridge{salt: salt}(address(this));

    arbitrumFork = vm.createSelectFork(vm.rpcUrl('arbitrum'), 148530087);
    bridgeArbitrum = new AaveArbEthERC20Bridge{salt: salt}(address(this));
  }
}

contract BridgeTest is AaveArbEthERC20BridgeTest {
  function test_revertsIf_invalidChain() public {
    vm.selectFork(mainnetFork);

    vm.expectRevert(AaveArbEthERC20Bridge.InvalidChain.selector);
    bridgeArbitrum.bridge(AaveV3EthereumAssets.USDC_UNDERLYING, 1_000e6);
  }

  function test_revertsIf_notOwner() public {
    vm.selectFork(arbitrumFork);

    uint256 amount = 1_000e6;

    vm.startPrank(USDC_WHALE);
    IERC20(AaveV3ArbitrumAssets.USDC_UNDERLYING).transfer(address(bridgeArbitrum), amount);
    vm.stopPrank();

    bridgeArbitrum.transferOwnership(GovernanceV3Arbitrum.EXECUTOR_LVL_1);

    vm.expectRevert('Ownable: caller is not the owner');
    bridgeArbitrum.bridge(AaveV3ArbitrumAssets.USDC_UNDERLYING, amount);
  }

  function test_successful() public {
    vm.selectFork(arbitrumFork);

    uint256 amount = 1_000e6;

    vm.startPrank(USDC_WHALE);
    IERC20(AaveV3ArbitrumAssets.USDC_UNDERLYING).transfer(address(bridgeArbitrum), amount);
    vm.stopPrank();

    bridgeArbitrum.transferOwnership(GovernanceV3Arbitrum.EXECUTOR_LVL_1);

    vm.startPrank(GovernanceV3Arbitrum.EXECUTOR_LVL_1);
    vm.expectEmit();
    emit Bridge(AaveV3ArbitrumAssets.USDC_UNDERLYING, amount);
    bridgeArbitrum.bridge(AaveV3ArbitrumAssets.USDC_UNDERLYING, amount);
    vm.stopPrank();
  }
}

contract EmergencyTokenTransfer is AaveArbEthERC20BridgeTest {
  function test_revertsIf_invalidCaller() public {
    vm.expectRevert('ONLY_RESCUE_GUARDIAN');
    vm.startPrank(makeAddr('random-caller'));
    bridgeArbitrum.emergencyTokenTransfer(
      AaveV3ArbitrumAssets.BAL_UNDERLYING,
      address(AaveV3Arbitrum.COLLECTOR),
      1_000e6
    );
    vm.stopPrank();
  }

  function test_successful_governanceCaller() public {
    address BAL_WHALE = 0x7Ba7f4773fa7890BaD57879F0a1Faa0eDffB3520;

    assertEq(IERC20(AaveV3ArbitrumAssets.BAL_UNDERLYING).balanceOf(address(bridgeArbitrum)), 0);

    uint256 balAmount = 1_000e18;

    vm.startPrank(BAL_WHALE);
    IERC20(AaveV3ArbitrumAssets.BAL_UNDERLYING).transfer(address(bridgeArbitrum), balAmount);
    vm.stopPrank();

    assertEq(IERC20(AaveV3ArbitrumAssets.BAL_UNDERLYING).balanceOf(address(bridgeArbitrum)), balAmount);

    uint256 initialCollectorBalBalance = IERC20(AaveV3ArbitrumAssets.BAL_UNDERLYING).balanceOf(
      address(AaveV3Arbitrumn.COLLECTOR)
    );

    bridgeArbitrum.emergencyTokenTransfer(
      AaveV3ArbitrumAssets.BAL_UNDERLYING,
      address(AaveV3Arbitrum.COLLECTOR),
      balAmount
    );

    assertEq(
      IERC20(AaveV3ArbitrumAssets.BAL_UNDERLYING).balanceOf(address(AaveV3Arbitrum.COLLECTOR)),
      initialCollectorBalBalance + balAmount
    );
    assertEq(IERC20(AaveV3ArbitrumAssets.BAL_UNDERLYING).balanceOf(address(bridgeArbitrum)), 0);
  }
}

contract WithdrawToCollectorTest is AaveArbEthERC20BridgeTest {
  function test_revertsIf_invalidChain() public {
    vm.selectFork(arbitrumFork);

    vm.expectRevert(AaveArbEthERC20Bridge.InvalidChain.selector);
    bridgeMainnet.withdrawToCollector(AaveV3EthereumAssets.USDC_UNDERLYING);
  }

  function test_successful() public {
    vm.selectFork(mainnetFork);

    uint256 amount = 1_000e6;

    vm.startPrank(USDC_WHALE_MAINNET);
    IERC20(AaveV3EthereumAssets.USDC_UNDERLYING).transfer(address(bridgeMainnet), amount);
    vm.stopPrank();

    uint256 balanceCollectorBefore = IERC20(AaveV3EthereumAssets.USDC_UNDERLYING).balanceOf(
      address(AaveV3Ethereum.COLLECTOR)
    );
    uint256 balanceBridgeBefore = IERC20(AaveV3EthereumAssets.USDC_UNDERLYING).balanceOf(
      address(bridgeMainnet)
    );

    assertEq(balanceBridgeBefore, amount);

    bridgeMainnet.withdrawToCollector(AaveV3EthereumAssets.USDC_UNDERLYING);

    assertEq(
      IERC20(AaveV3EthereumAssets.USDC_UNDERLYING).balanceOf(address(AaveV3Ethereum.COLLECTOR)),
      balanceCollectorBefore + amount
    );
    assertEq(IERC20(AaveV3EthereumAssets.USDC_UNDERLYING).balanceOf(address(bridgeMainnet)), 0);
  }
}

/*
 * No good way of testing the full flow as proof is generated via API ~7 days after the
 * bridge() function is called on Arbitrum.
 */
contract ExitTest is AaveArbEthERC20BridgeTest {
  function test_revertsIf_invalidChain() public {
    vm.selectFork(arbitrumFork);

    vm.expectRevert(AaveArbEthERC20Bridge.InvalidChain.selector);
    bridgeMainnet.exit(new bytes(0));
  }
}

contract TransferOwnership is AaveArbEthERC20BridgeTest {
  function test_revertsIf_invalidCaller() public {
    vm.startPrank(makeAddr('random-caller'));
    vm.expectRevert('Ownable: caller is not the owner');
    bridgeMainnet.transferOwnership(makeAddr('new-admin'));
    vm.stopPrank();
  }

  function test_successful() public {
    address newAdmin = GovernanceV3Ethereum.EXECUTOR_LVL_1;
    bridgeMainnet.transferOwnership(newAdmin);

    assertEq(newAdmin, bridgeMainnet.owner());
  }
}
