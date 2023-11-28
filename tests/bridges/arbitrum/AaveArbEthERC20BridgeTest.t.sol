// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from 'forge-std/Test.sol';
import {IERC20} from 'solidity-utils/contracts/oz-common/interfaces/IERC20.sol';
import {AaveV3Ethereum, AaveV3EthereumAssets} from 'aave-address-book/AaveV3Ethereum.sol';
import {AaveV3Arbitrum, AaveV3ArbitrumAssets} from 'aave-address-book/AaveV3Arbitrum.sol';
import {GovernanceV3Ethereum} from 'aave-address-book/GovernanceV3Ethereum.sol';
import {GovernanceV3Arbitrum} from 'aave-address-book/GovernanceV3Arbitrum.sol';

import {AaveArbEthERC20Bridge} from '../../../src/bridges/arbitrum/AaveArbEthERC20Bridge.sol';

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

  address USDC_WHALE = 0xb874005cbEa25C357b31C62145b3AEF219d105CF;
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
  address public constant USDC_GATEWAY = 0x096760F208390250649E3e8763348E783AEF5562;
  address public constant ARB_SYS = 0x0000000000000000000000000000000000000064; // pre-compiled

  function test_revertsIf_invalidChain() public {
    vm.selectFork(mainnetFork);

    vm.expectRevert(AaveArbEthERC20Bridge.InvalidChain.selector);
    bridgeArbitrum.bridge(
      AaveV3ArbitrumAssets.USDC_UNDERLYING,
      AaveV3EthereumAssets.USDC_UNDERLYING,
      USDC_GATEWAY,
      1_000e6
    );
  }

  function test_revertsIf_notOwner() public {
    vm.selectFork(arbitrumFork);

    uint256 amount = 1_000e6;

    vm.startPrank(USDC_WHALE);
    IERC20(AaveV3ArbitrumAssets.USDC_UNDERLYING).transfer(address(bridgeArbitrum), amount);
    vm.stopPrank();

    bridgeArbitrum.transferOwnership(GovernanceV3Arbitrum.EXECUTOR_LVL_1);

    vm.expectRevert('Ownable: caller is not the owner');
    bridgeArbitrum.bridge(
      AaveV3ArbitrumAssets.USDC_UNDERLYING,
      AaveV3EthereumAssets.USDC_UNDERLYING,
      USDC_GATEWAY,
      amount
    );
  }

  function test_successful_arbitrumBridge() public {
    vm.selectFork(arbitrumFork);

    bytes memory mockedData = hex'2e567b36000000000000000000000000a0b86991c6218b36c1d19d4a2e9eb0ce3606eb48000000000000000000000000217666a199d87740a10879db279556cb99b76534000000000000000000000000464c71f6c2f760dda6093dcb91c24c39e5d6e18c000000000000000000000000000000000000000000000000000000003b9aca0000000000000000000000000000000000000000000000000000000000000000a0000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000037d900000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000';

    uint256 amount = 1_000e6;

    vm.startPrank(USDC_WHALE);
    IERC20(AaveV3ArbitrumAssets.USDC_UNDERLYING).transfer(address(bridgeArbitrum), amount);
    vm.stopPrank();

    bridgeArbitrum.transferOwnership(GovernanceV3Arbitrum.EXECUTOR_LVL_1);

    vm.startPrank(GovernanceV3Arbitrum.EXECUTOR_LVL_1);
    vm.expectEmit();
    emit Bridge(AaveV3ArbitrumAssets.USDC_UNDERLYING, amount);

    vm.mockCall(
      ARB_SYS,
      abi.encodeWithSelector(0x928c169a, USDC_WHALE_MAINNET, mockedData),
      abi.encode(uint256(1))
    );
    bridgeArbitrum.bridge(
      AaveV3ArbitrumAssets.USDC_UNDERLYING,
      AaveV3EthereumAssets.USDC_UNDERLYING,
      USDC_GATEWAY,
      amount
    );
    vm.stopPrank();
  }
}

contract EmergencyTokenTransfer is AaveArbEthERC20BridgeTest {
  function test_revertsIf_invalidCaller() public {
    vm.expectRevert('ONLY_RESCUE_GUARDIAN');
    vm.startPrank(makeAddr('random-caller'));
    bridgeArbitrum.emergencyTokenTransfer(
      AaveV3ArbitrumAssets.LINK_UNDERLYING,
      address(AaveV3Arbitrum.COLLECTOR),
      1_000e6
    );
    vm.stopPrank();
  }

  function test_successful_governanceCaller() public {
    address LINK_WHALE = 0x191c10Aa4AF7C30e871E70C95dB0E4eb77237530;

    assertEq(IERC20(AaveV3ArbitrumAssets.LINK_UNDERLYING).balanceOf(address(bridgeArbitrum)), 0);

    uint256 balAmount = 1_000e18;

    vm.startPrank(LINK_WHALE);
    IERC20(AaveV3ArbitrumAssets.LINK_UNDERLYING).transfer(address(bridgeArbitrum), balAmount);
    vm.stopPrank();

    assertEq(
      IERC20(AaveV3ArbitrumAssets.LINK_UNDERLYING).balanceOf(address(bridgeArbitrum)),
      balAmount
    );

    uint256 initialCollectorBalBalance = IERC20(AaveV3ArbitrumAssets.LINK_UNDERLYING).balanceOf(
      address(AaveV3Arbitrum.COLLECTOR)
    );

    bridgeArbitrum.emergencyTokenTransfer(
      AaveV3ArbitrumAssets.LINK_UNDERLYING,
      address(AaveV3Arbitrum.COLLECTOR),
      balAmount
    );

    assertEq(
      IERC20(AaveV3ArbitrumAssets.LINK_UNDERLYING).balanceOf(address(AaveV3Arbitrum.COLLECTOR)),
      initialCollectorBalBalance + balAmount
    );
    assertEq(IERC20(AaveV3ArbitrumAssets.LINK_UNDERLYING).balanceOf(address(bridgeArbitrum)), 0);
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
    // bridgeMainnet.exit(new bytes(0));
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
