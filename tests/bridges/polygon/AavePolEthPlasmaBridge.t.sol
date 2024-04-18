// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Test} from 'forge-std/Test.sol';
import {IERC20} from 'solidity-utils/contracts/oz-common/interfaces/IERC20.sol';
import {AaveV3Ethereum, AaveV3EthereumAssets} from 'aave-address-book/AaveV3Ethereum.sol';
import {AaveV2Polygon, AaveV2PolygonAssets} from 'aave-address-book/AaveV2Polygon.sol';
import {AaveV3Polygon, AaveV3PolygonAssets} from 'aave-address-book/AaveV3Polygon.sol';
import {MiscEthereum} from 'aave-address-book/MiscEthereum.sol';
import {GovernanceV3Ethereum} from 'aave-address-book/GovernanceV3Ethereum.sol';
import {GovernanceV3Polygon} from 'aave-address-book/GovernanceV3Polygon.sol';

import {AavePolEthPlasmaBridge} from 'src/bridges/polygon/AavePolEthPlasmaBridge.sol';
import {IAavePolEthPlasmaBridge} from 'src/bridges/polygon/IAavePolEthPlasmaBridge.sol';

contract AavePolEthPlasmaBridgeTest is Test {
  event Bridge(address token, uint256 amount);
  event ConfirmExit(bytes proof);
  event Exit(address indexed token);
  event ExitBatch(address[] indexed tokens);
  event WithdrawToCollector(address token, uint256 amount);

  address public constant WHALE = 0xe7804c37c13166fF0b37F5aE0BB07A3aEbb6e245;
  address public constant USDC_WHALE_MAINNET = 0xcEe284F754E854890e311e3280b767F80797180d;
  address public constant NATIVE_MATIC = 0x0000000000000000000000000000000000001010;

  AavePolEthPlasmaBridge bridgeMainnet;
  AavePolEthPlasmaBridge bridgePolygon;
  uint256 mainnetFork;
  uint256 polygonFork;

  function setUp() public {
    bytes32 salt = keccak256(abi.encode(tx.origin, uint256(0)));

    mainnetFork = vm.createSelectFork(vm.rpcUrl('mainnet'), 19321284);
    bridgeMainnet = new AavePolEthPlasmaBridge{salt: salt}(address(this));

    polygonFork = vm.createSelectFork(vm.rpcUrl('polygon'), 54032678);
    bridgePolygon = new AavePolEthPlasmaBridge{salt: salt}(address(this));
  }
}

contract BridgeTest is AavePolEthPlasmaBridgeTest {
  function test_revertsIf_invalidChain() public {
    vm.selectFork(mainnetFork);

    vm.expectRevert(IAavePolEthPlasmaBridge.InvalidChain.selector);
    bridgePolygon.bridge(AaveV3EthereumAssets.USDC_UNDERLYING, 1_000e6);
  }

  function test_revertsIf_notOwner() public {
    vm.selectFork(polygonFork);

    uint256 amount = 1_000e6;

    vm.startPrank(WHALE);
    IERC20(NATIVE_MATIC).transfer(address(bridgePolygon), amount);
    vm.stopPrank();

    bridgePolygon.transferOwnership(GovernanceV3Polygon.EXECUTOR_LVL_1);

    vm.expectRevert('Ownable: caller is not the owner');
    bridgePolygon.bridge(NATIVE_MATIC, amount);
  }

  function test_successful() public {
    vm.selectFork(polygonFork);

    uint256 amount = 1_000e6;

    deal(address(bridgePolygon), amount);

    bridgePolygon.transferOwnership(GovernanceV3Polygon.EXECUTOR_LVL_1);

    vm.startPrank(GovernanceV3Polygon.EXECUTOR_LVL_1);
    vm.expectEmit();
    emit Bridge(NATIVE_MATIC, amount);
    bridgePolygon.bridge(NATIVE_MATIC, amount);
    vm.stopPrank();
  }
}

contract TransferOwnership is AavePolEthPlasmaBridgeTest {
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

contract WithdrawToCollectorTest is AavePolEthPlasmaBridgeTest {
  function test_revertsIf_invalidChain() public {
    vm.selectFork(polygonFork);

    vm.expectRevert(IAavePolEthPlasmaBridge.InvalidChain.selector);
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

contract EmergencyTokenTransfer is AavePolEthPlasmaBridgeTest {
  function test_revertsIf_invalidCaller() public {
    vm.expectRevert('ONLY_RESCUE_GUARDIAN');
    vm.startPrank(makeAddr('random-caller'));
    bridgePolygon.emergencyTokenTransfer(
      AaveV2PolygonAssets.BAL_UNDERLYING,
      address(AaveV2Polygon.COLLECTOR),
      1_000e6
    );
    vm.stopPrank();
  }

  function test_successful_governanceCaller() public {
    address LINK_WHALE = 0x61167073E31b1DAd85a3E531211c7B8F1E5cAE72;

    assertEq(IERC20(AaveV2PolygonAssets.LINK_UNDERLYING).balanceOf(address(bridgePolygon)), 0);

    uint256 balAmount = 1_000e18;

    vm.startPrank(LINK_WHALE);
    IERC20(AaveV2PolygonAssets.LINK_UNDERLYING).transfer(address(bridgePolygon), balAmount);
    vm.stopPrank();

    assertEq(
      IERC20(AaveV2PolygonAssets.LINK_UNDERLYING).balanceOf(address(bridgePolygon)),
      balAmount
    );

    uint256 initialCollectorBalBalance = IERC20(AaveV2PolygonAssets.LINK_UNDERLYING).balanceOf(
      address(AaveV2Polygon.COLLECTOR)
    );

    bridgePolygon.emergencyTokenTransfer(
      AaveV2PolygonAssets.LINK_UNDERLYING,
      address(AaveV2Polygon.COLLECTOR),
      balAmount
    );

    assertEq(
      IERC20(AaveV2PolygonAssets.LINK_UNDERLYING).balanceOf(address(AaveV2Polygon.COLLECTOR)),
      initialCollectorBalBalance + balAmount
    );
    assertEq(IERC20(AaveV2PolygonAssets.LINK_UNDERLYING).balanceOf(address(bridgePolygon)), 0);
  }
}

/*
 * No good way of testing the full flow as proof is generated via API 30-90 minutes after the
 * bridge() function is called on Polygon.
 */
contract ExitTest is AavePolEthPlasmaBridgeTest {
  function test_revertsIf_invalidChain() public {
    vm.selectFork(polygonFork);

    vm.expectRevert(IAavePolEthPlasmaBridge.InvalidChain.selector);
    bridgeMainnet.confirmExit(new bytes(0));
  }

  function test_revertsIf_proofAlreadyProcessed() public {
    vm.selectFork(mainnetFork);

    bytes
      memory burnProof = hex'f90d298422e1e6b0b90120433b0d2d0234f58cd9e8404894ba9f3687fc8b0927c359b4c9977f182677eed901942bbf20f1fd9032d1b173b911d2e1d9c0c9de6ae79f6e1330d16e09c833ca452ce56e950ea226ca527012f881475efdd7c622f17394e632a743de1ef352a8b72395afa69ed1137763e1c64f796e1e90a7b85f377f95f03d3ea1eba29f7ee50a60268d6d6a86697fd881c0f18ea8e643b3365e7dc533940650d7606b9d824994b9a9c26e68990484952e8955fdbb8a01177074bc0872e63af46be69c9a0ee3150e0114ebc8a68469240747e157b6a667ed8df73ec4560b77dd60c6dcc1d47517e30d0a87fde2ab53b50ba69a2355ba1086b1b9b88648a8110c4f01a0c57d952b9e4499ec65c0442fc2210d7a54856bb36d5b5fb080f1bfb36b0df40d04cdd784033864598465de198ba0ba95e013f19a21f66a47256c2e42b006ec54f3d13e4cd4ce32cbdba025859e46a01c7d305fdf034cd665c96da4d8902557e4e29b54116e0fd4a235fb16421248d6b9046d02f90469018303f667b9010000000000000000000000000000000000000200000000000000000000000000000000000000000000000810100000000000008000000000000000000000000000000000000000000000000000000000800000000000000000000100000000000000000000000080000000000000000000000000000020000080000000001000000000000000000000080000000000000000000000000004000000000000000000200000000000000000000000000000000000000000000000000000000000004000000000000000000001000000000000000000000000800000108000200000000100000000000000080000000000000000000000000000000000000000100000f9035ef9013d940000000000000000000000000000000000001010f884a0e6497e3ee548a3372136af2fcb0696db31fc6cf20260707645068bd3fe97f3c4a00000000000000000000000000000000000000000000000000000000000001010a0000000000000000000000000ebaca92a7be0b5f658c0770a81951bba22da5638a00000000000000000000000000000000000000000000000000000000000001010b8a00000000000000000000000000000000000000000000008812d5ac25c01b45bf000000000000000000000000000000000000000000000088133e07ef64641f1f000000000000000000000000000000000000000001c5e2e002e82004460d76f970000000000000000000000000000000000000000000000000685bc9a448d960000000000000000000000000000000000000000001c5e36815bdcc2a0628bcb87f8dc940000000000000000000000000000000000001010f863a0ebff2602b3f468259e1e99f613fed6691f3a6526effe6ef3e768ba7ae7a36c4fa00000000000000000000000007d1afa7b718fb893db30a3abc0cfc608aacfebb0a0000000000000000000000000ebaca92a7be0b5f658c0770a81951bba22da5638b8600000000000000000000000000000000000000000000008812d5ac25c01b45bf00000000000000000000000000000000000000000000000000685bc9a448d96000000000000000000000000000000000000000000000000000685bc9a448d9600f9013d940000000000000000000000000000000000001010f884a04dfe1bbbcf077ddc3e01291eea2d5c70c2b422b415d95645b9adcfd678cb1d63a00000000000000000000000000000000000000000000000000000000000001010a0000000000000000000000000ebaca92a7be0b5f658c0770a81951bba22da5638a0000000000000000000000000fcccd43296d9c1601a904eca9b339d94a5e5e098b8a00000000000000000000000000000000000000000000000000008ff34526de00000000000000000000000000000000000000000000000088134d9397f946a5bf00000000000000000000000000000000000000000000009e56bc92173ffaf923400000000000000000000000000000000000000000000088134d03a4b41fc7bf00000000000000000000000000000000000000000000009e56bd220a8521d7234b9073ef9073bf8d1a0d6213f494e7bb1418661069c6da13302d80fb5401182aa96d08220bc0dc8e071a09f6c1782a3c25bf4f666c950141efa981d6e384dcba2f7d6e187494e6b6da64ea0e2802b6c219907c6c4df3941d375d6af0178a87942214cd316153b7b80ba0b86a028698766cbf0cbe3ea9d11207f42080892266da139cbb88dfde2f61e9110f094a0bd71b87290463b0d762268927681cc8eb886ab9aa795e17afdb805288c72b515808080a0ace20d838d862dad238ab335ab3beaee728905d708276f3cb0959ef87a4c862f8080808080808080f901f180a034a531f189309d3615eaa5355b802540eec79d070a52783155500c7b6dbd90f3a038c800c74acdbfb17409a84d9fec28ddb1880095996693fe214604e8b41f02dba027d6ab89f4c64dc0fbd39a63fed8aa2456afc345c8d56e3b1f035dc58027b7f4a03260d7a2ef33945fff14a7d4254a54eb4dddfe2c8666296fc84d726532044082a0f218f242a23fb2006706d42b3e962e6606d5bae8ee2ee46dccd20c51479ae8dda060def2876dd04c270193c01b0911bcb2cf205bdd97fde1b411c1af54b98eb90fa09031ddbf92abfdcf8a5097ec49926df6ce56c600c1e9ecfd6ac5dff3003ddfc0a04962eac743a962f31f72999756fb6280262a2795ed61c5af866352aa140c63ada0bcaaf83e7f037d8965cff1cc28f1580c33958d46717fbf8556b3cea24a78b657a0c843c1561e9e5b73f9dd8b9dbf76d642509dac5f2c8181e8eabc09ec1ebfd1dda09686974194e882ff96c8c8dc0d4adee666b6ea074f6d297fc3de17e0de35b460a0408c89cc15230136f4a3d3e945d8c9ff1affe7360315de4079162eef95164210a0550a8f4f040ebf7fc1c58c4c0689f9e97b0079ef8d29d3ac31471e3d05e52e0da0a8fe18a87d802e43448d1b9ad5c0e3029018a1b47ba25dc2e8f85e82d8dfcaf3a045053b7bbc7d3081fdbc9eb37620c558888a8e9e8deabc89ada98a599862f88080f9047120b9046d02f90469018303f667b9010000000000000000000000000000000000000200000000000000000000000000000000000000000000000810100000000000008000000000000000000000000000000000000000000000000000000000800000000000000000000100000000000000000000000080000000000000000000000000000020000080000000001000000000000000000000080000000000000000000000000004000000000000000000200000000000000000000000000000000000000000000000000000000000004000000000000000000001000000000000000000000000800000108000200000000100000000000000080000000000000000000000000000000000000000100000f9035ef9013d940000000000000000000000000000000000001010f884a0e6497e3ee548a3372136af2fcb0696db31fc6cf20260707645068bd3fe97f3c4a00000000000000000000000000000000000000000000000000000000000001010a0000000000000000000000000ebaca92a7be0b5f658c0770a81951bba22da5638a00000000000000000000000000000000000000000000000000000000000001010b8a00000000000000000000000000000000000000000000008812d5ac25c01b45bf000000000000000000000000000000000000000000000088133e07ef64641f1f000000000000000000000000000000000000000001c5e2e002e82004460d76f970000000000000000000000000000000000000000000000000685bc9a448d960000000000000000000000000000000000000000001c5e36815bdcc2a0628bcb87f8dc940000000000000000000000000000000000001010f863a0ebff2602b3f468259e1e99f613fed6691f3a6526effe6ef3e768ba7ae7a36c4fa00000000000000000000000007d1afa7b718fb893db30a3abc0cfc608aacfebb0a0000000000000000000000000ebaca92a7be0b5f658c0770a81951bba22da5638b8600000000000000000000000000000000000000000000008812d5ac25c01b45bf00000000000000000000000000000000000000000000000000685bc9a448d96000000000000000000000000000000000000000000000000000685bc9a448d9600f9013d940000000000000000000000000000000000001010f884a04dfe1bbbcf077ddc3e01291eea2d5c70c2b422b415d95645b9adcfd678cb1d63a00000000000000000000000000000000000000000000000000000000000001010a0000000000000000000000000ebaca92a7be0b5f658c0770a81951bba22da5638a0000000000000000000000000fcccd43296d9c1601a904eca9b339d94a5e5e098b8a00000000000000000000000000000000000000000000000000008ff34526de00000000000000000000000000000000000000000000000088134d9397f946a5bf00000000000000000000000000000000000000000000009e56bc92173ffaf923400000000000000000000000000000000000000000000088134d03a4b41fc7bf00000000000000000000000000000000000000000000009e56bd220a8521d723482000501';

    vm.expectRevert('Withdrawer and burn exit tx do not match');
    bridgeMainnet.confirmExit(burnProof);
  }
}

/// This is a real proof that was manually created by efecarranza.eth
/// The TX can be found here: https://etherscan.io/tx/0x75849d87d15d6a5837c29e2d97a10a442fa71bee50c8cb8ddc01058a474e581e
contract ForkedBridgeTests is Test {
  function test_successful() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), 19419577); // One block before an actual exit

    bytes
      memory burnProof = hex'f90e4884233313f0b90160079c12baaa97cc4e197b379b04a0d04ff537b78de94c227d7b4c87c0d1dda4d040f844fd8ecd0959992f9f812c75b20b35fb22cc411e380440d4725f4654f2e8cb46ce66478ede0f30b8d7c2b8e05f8847fb92ee757dc4c958bc529981857a94c62ca2806fc3f04375fd482fa489f82f2f673d39f3885ea68d8163df00f9bde29b5596294480d231e68f32ed3825adeb8f0d8ecb71b823a76b6600245232128b87e25049d52f33341db8e5ccb3d5eba0c7c2aa14e5386ec387cd3126ccc21e2e62dbab2f63152fcecdf13977d662499c4d72c0f640ceaa9dc16619be69688d04189d212019c5e81c2735501c2ad17542304f0fe046796e959acdd0ffd1c2b109b048e06661087638c7dab809ede06f174232b5e1699cc295bd6f85b3c69ade936de28d0f1c0c0aa05370c2e28440590d18b25fb7bfbf9ba0198bd2eb467f91576109f3ed268808bb10b629748ab1dcfe7f84c99986f4df1f4eabca070999d92e84033f836c8465edc5b4a0d9f0e66f0783529b6f1c45593d7e1dcd1072fac53d47510a4a2f1ade9d29b632a063fd6c1c65e072cd9a1e639ed10a55fae606006c4b91dfe75df2a09b95fa44dbb904e902f904e5018401035d74b9010000000000000004000800000000000000000000000000000000000000880000000000080000000000000812100000000800008000000000000000000000000000200000000000000000000000000000800000000000000000000108000000000001000000000000000000000000000000000000000020000080000000001000000000000000000000000000000000010000000000000004000000000020000000200000000000000000000000000000000000000000000000000000000000004000000100000000000001000000000000000000000000800000108000280000002000000000000000000000000000000000000000000000000000000000100000f903d9f9013d940000000000000000000000000000000000001010f884a0e6497e3ee548a3372136af2fcb0696db31fc6cf20260707645068bd3fe97f3c4a00000000000000000000000000000000000000000000000000000000000001010a0000000000000000000000000752d9470d6895ffce597dac750d7e7cb602dd543a00000000000000000000000000000000000000000000000000000000000001010b8a000000000000000000000000000000000000000000000000006f05b59d3b2000000000000000000000000000000000000000000000000000006f05b59d3b2000000000000000000000000000000000000000000001c56091b1cdceef7ed6018e8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001c56091b23cd4a51c11218e8f8dc940000000000000000000000000000000000001010f863a0ebff2602b3f468259e1e99f613fed6691f3a6526effe6ef3e768ba7ae7a36c4fa00000000000000000000000007d1afa7b718fb893db30a3abc0cfc608aacfebb0a0000000000000000000000000752d9470d6895ffce597dac750d7e7cb602dd543b86000000000000000000000000000000000000000000000000006f05b59d3b2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f87994752d9470d6895ffce597dac750d7e7cb602dd543e1a022e3f162fca16dc0fcfb65eddf406531a0c555a2c24c58cf5d10fc2d202a882eb840000000000000000000000000000000000000000000000000000000000000101000000000000000000000000000000000000000000000000006f05b59d3b20000f9013d940000000000000000000000000000000000001010f884a04dfe1bbbcf077ddc3e01291eea2d5c70c2b422b415d95645b9adcfd678cb1d63a00000000000000000000000000000000000000000000000000000000000001010a00000000000000000000000003765a685a401622c060e5d700d9ad89413363a91a00000000000000000000000001efecb61a2f80aa34d3b9218b564a64d05946290b8a00000000000000000000000000000000000000000000000000004d3752576800000000000000000000000000000000000000000000000000030e709f5c54d02f5000000000000000000000000000000000000000000000810f6987c14573200cd00000000000000000000000000000000000000000000000030e236809fd682f5000000000000000000000000000000000000000000000810f69d4f897ca880cdb907a0f9079df90131a0cc6bad86ebf0f818392a12389f3bc53ebb9f94d27e9d0382d6a9db32d9c5de60a04b991800dfddc8b77c5ebd60e3abf0060bcb562f14ec3dacaf98e1ee10708b39a0a2ffea0972a886f6b61dd075bb593b214015d9bfc32f67dae13e29d91a49642da0136e0359a298c70878e9bbe9c7dc94bb775e4d91bcb7b21e79eb19e095899245a083b67235f8289fe24e85c5bb06fafef5d3d4c0d79213df82db59addabd09d902a0100bd7b2f394a1a9a735c20202824adcf96d5d0a70ff9263115baa0d7ffb3a7aa02aef965259bc088c423c15851cebd20f620013c42d1e2d0dfb7e9abdc1686d6ca04f996c1ee338e580e92ed19929d48004c61e43c84529057d074413547b7104e9a0d5a7f9411f393475392c386c78c04fb84d62e6c576ea494cb52a0bd397774ea98080808080808080f851a06715f19145ea190bac587bc8c167cf3c8dd68ae34e2310afeb5c443cb69c071ca0121575898ad38143b1859b1027ab00ef467464a5780bcebb2d6450c57f6e1c40808080808080808080808080808080f8918080808080808080a0d77f25545d6e8133022a5b6c177b2ad66d0be9375f856efd1f946f0a04966505a092b20e32a9ea59c9a1c3e2a5e6b7d90cf33a0ab2bae06c057b1e8a8e84ec3a04a051352578e2e8157b2859d1d79d12b77378c2b5dc47b066f071e0407b36b15bb4a0412b67856079f6d507f8a509329810d649a339a1504ca001739676aafd50b2718080808080f891a0a3a3aee21f0483dbfae1feec7566cd4a6612a553478f267cae62a00117d7fa3fa0a58c0f7532d68fcdfb97e0da91cd690ca6b45d6778bf07946b1da2d9c04a5c10a0aa79cc36876636b0daa60eacf1d85bfd0101afcda5939b6c3e09ca5514ea645ca04d502874cec64708160342c328195c93349b6a86b2f8624ac3b9b17f1257f4d480808080808080808080808080f904ed20b904e902f904e5018401035d74b9010000000000000004000800000000000000000000000000000000000000880000000000080000000000000812100000000800008000000000000000000000000000200000000000000000000000000000800000000000000000000108000000000001000000000000000000000000000000000000000020000080000000001000000000000000000000000000000000010000000000000004000000000020000000200000000000000000000000000000000000000000000000000000000000004000000100000000000001000000000000000000000000800000108000280000002000000000000000000000000000000000000000000000000000000000100000f903d9f9013d940000000000000000000000000000000000001010f884a0e6497e3ee548a3372136af2fcb0696db31fc6cf20260707645068bd3fe97f3c4a00000000000000000000000000000000000000000000000000000000000001010a0000000000000000000000000752d9470d6895ffce597dac750d7e7cb602dd543a00000000000000000000000000000000000000000000000000000000000001010b8a000000000000000000000000000000000000000000000000006f05b59d3b2000000000000000000000000000000000000000000000000000006f05b59d3b2000000000000000000000000000000000000000000001c56091b1cdceef7ed6018e8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001c56091b23cd4a51c11218e8f8dc940000000000000000000000000000000000001010f863a0ebff2602b3f468259e1e99f613fed6691f3a6526effe6ef3e768ba7ae7a36c4fa00000000000000000000000007d1afa7b718fb893db30a3abc0cfc608aacfebb0a0000000000000000000000000752d9470d6895ffce597dac750d7e7cb602dd543b86000000000000000000000000000000000000000000000000006f05b59d3b2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f87994752d9470d6895ffce597dac750d7e7cb602dd543e1a022e3f162fca16dc0fcfb65eddf406531a0c555a2c24c58cf5d10fc2d202a882eb840000000000000000000000000000000000000000000000000000000000000101000000000000000000000000000000000000000000000000006f05b59d3b20000f9013d940000000000000000000000000000000000001010f884a04dfe1bbbcf077ddc3e01291eea2d5c70c2b422b415d95645b9adcfd678cb1d63a00000000000000000000000000000000000000000000000000000000000001010a00000000000000000000000003765a685a401622c060e5d700d9ad89413363a91a00000000000000000000000001efecb61a2f80aa34d3b9218b564a64d05946290b8a00000000000000000000000000000000000000000000000000004d3752576800000000000000000000000000000000000000000000000000030e709f5c54d02f5000000000000000000000000000000000000000000000810f6987c14573200cd00000000000000000000000000000000000000000000000030e236809fd682f5000000000000000000000000000000000000000000000810f69d4f897ca880cd830081b101';
    IAavePolEthPlasmaBridge(0x752d9470D6895fFCE597DAC750d7E7CB602dd543).confirmExit(burnProof);
  }
}