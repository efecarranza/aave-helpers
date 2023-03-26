```diff
diff --git a/./reports/preTestEnginePriceFeed.json b/./reports/postTestEnginePriceFeed.json
index 806a837..582a64a 100644
--- a/./reports/preTestEnginePriceFeed.json
+++ b/./reports/postTestEnginePriceFeed.json
@@ -1,726 +1,726 @@
 {
   "poolConfig": {
     "oracle": "0xb023e699F5a33916Ea823A16485e259257cA8Bd1",
     "poolAddressesProvider": "0xa97684ead0e402dC232d5A977953DF7ECBaB3CDb",
     "protocolDataProvider": "0x69FA688f1Dc47d4B5d8029D5a35FB7a548310654",
     "pool": "0x794a61358D6845594F94dc1DB02A252b5b4814aD",
     "poolConfigurator": "0x8145eddDf43f50276641b55bd3AD95944510021E",
     "poolConfiguratorImpl": "0xD6FA681E22306b0F4E605B979b7c9a1dFa865ade",
     "poolImpl": "0xDF9e4ABdbd94107932265319479643D3B05809dc"
   },
   "strategies": {
     "0x41B66b4b6b4c9dab039d96528D1b88f7BAF8C5A4": {
       "maxExcessStableToTotalDebtRatio": 800000000000000000000000000,
       "address": "0x41B66b4b6b4c9dab039d96528D1b88f7BAF8C5A4",
       "stableRateSlope1": 5000000000000000000000000,
       "baseStableBorrowRate": 50000000000000000000000000,
       "stableRateSlope2": 600000000000000000000000000,
       "baseVariableBorrowRate": 0,
       "variableRateSlope1": 40000000000000000000000000,
       "optimalUsageRatio": 900000000000000000000000000,
       "optimalStableToTotalDebtRatio": 200000000000000000000000000,
       "maxExcessUsageRatio": 100000000000000000000000000,
       "variableRateSlope2": 600000000000000000000000000
     },
     "0x4b8D3277d49E114C8F2D6E0B2eD310e29226fe16": {
       "variableRateSlope2": 1500000000000000000000000000,
       "stableRateSlope2": 0,
       "baseVariableBorrowRate": 30000000000000000000000000,
       "variableRateSlope1": 140000000000000000000000000,
       "maxExcessStableToTotalDebtRatio": 800000000000000000000000000,
       "maxExcessUsageRatio": 200000000000000000000000000,
       "optimalUsageRatio": 800000000000000000000000000,
       "optimalStableToTotalDebtRatio": 200000000000000000000000000,
       "address": "0x4b8D3277d49E114C8F2D6E0B2eD310e29226fe16",
       "stableRateSlope1": 0,
       "baseStableBorrowRate": 160000000000000000000000000
     },
     "0xFB0898dCFb69DF9E01DBE625A5988D6542e5BdC5": {
       "optimalUsageRatio": 750000000000000000000000000,
       "address": "0xFB0898dCFb69DF9E01DBE625A5988D6542e5BdC5",
       "baseStableBorrowRate": 81000000000000000000000000,
       "baseVariableBorrowRate": 0,
       "optimalStableToTotalDebtRatio": 200000000000000000000000000,
       "stableRateSlope2": 0,
       "variableRateSlope1": 61000000000000000000000000,
       "variableRateSlope2": 1000000000000000000000000000,
       "maxExcessStableToTotalDebtRatio": 800000000000000000000000000,
       "maxExcessUsageRatio": 250000000000000000000000000,
       "stableRateSlope1": 0
     },
     "0xA9F3C3caE095527061e6d270DBE163693e6fda9D": {
       "stableRateSlope1": 5000000000000000000000000,
       "variableRateSlope2": 750000000000000000000000000,
       "variableRateSlope1": 40000000000000000000000000,
       "baseStableBorrowRate": 50000000000000000000000000,
       "stableRateSlope2": 750000000000000000000000000,
       "baseVariableBorrowRate": 0,
       "optimalStableToTotalDebtRatio": 200000000000000000000000000,
       "maxExcessStableToTotalDebtRatio": 800000000000000000000000000,
       "optimalUsageRatio": 800000000000000000000000000,
       "maxExcessUsageRatio": 200000000000000000000000000,
       "address": "0xA9F3C3caE095527061e6d270DBE163693e6fda9D"
     },
     "0x03733F4E008d36f2e37F0080fF1c8DF756622E6F": {
       "stableRateSlope2": 0,
       "optimalStableToTotalDebtRatio": 200000000000000000000000000,
       "maxExcessUsageRatio": 550000000000000000000000000,
       "stableRateSlope1": 0,
       "variableRateSlope2": 3000000000000000000000000000,
       "variableRateSlope1": 70000000000000000000000000,
       "baseStableBorrowRate": 90000000000000000000000000,
       "address": "0x03733F4E008d36f2e37F0080fF1c8DF756622E6F",
       "maxExcessStableToTotalDebtRatio": 800000000000000000000000000,
       "optimalUsageRatio": 450000000000000000000000000,
       "baseVariableBorrowRate": 0
     }
   },
   "chainId": 137,
   "eModes": {
     "1": {
       "label": "Stablecoins",
       "ltv": 9700,
       "eModeCategory": 1,
       "liquidationThreshold": 9750,
       "liquidationBonus": 10100,
       "priceSource": "0x0000000000000000000000000000000000000000"
     },
     "2": {
       "ltv": 9250,
       "eModeCategory": 2,
       "liquidationThreshold": 9500,
       "liquidationBonus": 10100,
       "priceSource": "0x0000000000000000000000000000000000000000",
       "label": "MATIC correlated"
     }
   },
   "reserves": {
     "0x9a71012B13CA4d3D0Cdc72A177DF3ef03b0E76A3": {
       "decimals": 18,
       "aTokenImpl": "0xa5ba6E5EC19a1Bf23C857991c857dB62b2Aa187B",
       "debtCeiling": 0,
       "stableBorrowRateEnabled": false,
       "liquidationProtocolFee": 1000,
       "borrowCap": 256140,
       "liquidationBonus": 11000,
       "usageAsCollateralEnabled": true,
       "stableDebtToken": "0xa5e408678469d23efDB7694b1B0A85BB0669e8bd",
       "reserveFactor": 2000,
       "stableDebtTokenImpl": "0x52A1CeB68Ee6b7B5D13E0376A1E0E4423A8cE26e",
       "symbol": "BAL",
       "isFrozen": false,
       "underlying": "0x9a71012B13CA4d3D0Cdc72A177DF3ef03b0E76A3",
       "aToken": "0x8ffDf2DE812095b1D19CB146E4c004587C0A0692",
       "liquidationThreshold": 4500,
       "interestRateStrategy": "0x4b8D3277d49E114C8F2D6E0B2eD310e29226fe16",
       "supplyCap": 361000,
       "isSiloed": false,
       "isFlashloanable": false,
       "eModeCategory": 0,
       "variableDebtToken": "0xA8669021776Bc142DfcA87c21b4A52595bCbB40a",
       "isBorrowableInIsolation": false,
       "isActive": true,
       "borrowingEnabled": true,
       "ltv": 2000,
       "variableDebtTokenImpl": "0x81387c40EB75acB02757C1Ae55D5936E78c9dEd3",
       "oracle": {
         "address": "0xD106B538F2A868c28Ca1Ec7E298C3325E0251d66",
         "latestAnswer": 649789451
       }
     },
     "0x0b3F868E0BE5597D5DB7fEB59E1CADBb0fdDa50a": {
       "symbol": "SUSHI",
       "ltv": 2000,
       "liquidationBonus": 11000,
       "decimals": 18,
       "debtCeiling": 0,
       "supplyCap": 299320,
       "isFrozen": false,
       "isFlashloanable": false,
       "stableBorrowRateEnabled": false,
       "interestRateStrategy": "0x03733F4E008d36f2e37F0080fF1c8DF756622E6F",
       "stableDebtTokenImpl": "0x52A1CeB68Ee6b7B5D13E0376A1E0E4423A8cE26e",
       "variableDebtTokenImpl": "0x81387c40EB75acB02757C1Ae55D5936E78c9dEd3",
       "usageAsCollateralEnabled": true,
       "borrowCap": 102484,
       "reserveFactor": 2000,
       "oracle": {
         "address": "0x49B0c695039243BBfEb8EcD054EB70061fd54aa0",
         "latestAnswer": 121170720
       },
       "isSiloed": false,
       "liquidationProtocolFee": 1000,
       "liquidationThreshold": 4500,
       "aToken": "0xc45A479877e1e9Dfe9FcD4056c699575a1045dAA",
       "underlying": "0x0b3F868E0BE5597D5DB7fEB59E1CADBb0fdDa50a",
       "variableDebtToken": "0x34e2eD44EF7466D5f9E0b782B5c08b57475e7907",
       "aTokenImpl": "0xa5ba6E5EC19a1Bf23C857991c857dB62b2Aa187B",
       "isActive": true,
       "isBorrowableInIsolation": false,
       "borrowingEnabled": true,
       "eModeCategory": 0,
       "stableDebtToken": "0x78246294a4c6fBf614Ed73CcC9F8b875ca8eE841"
     },
     "0xE111178A87A3BFf0c8d18DECBa5798827539Ae99": {
       "isBorrowableInIsolation": false,
       "liquidationThreshold": 7000,
       "supplyCap": 4000000,
       "usageAsCollateralEnabled": true,
       "liquidationBonus": 10750,
       "debtCeiling": 500000000,
       "borrowingEnabled": true,
       "stableBorrowRateEnabled": true,
       "reserveFactor": 1000,
       "isSiloed": false,
       "isFlashloanable": false,
       "interestRateStrategy": "0x41B66b4b6b4c9dab039d96528D1b88f7BAF8C5A4",
       "isFrozen": false,
       "underlying": "0xE111178A87A3BFf0c8d18DECBa5798827539Ae99",
       "symbol": "EURS",
       "stableDebtToken": "0x8a9FdE6925a839F6B1932d16B36aC026F8d3FbdB",
       "decimals": 2,
       "borrowCap": 947000,
       "aTokenImpl": "0xa5ba6E5EC19a1Bf23C857991c857dB62b2Aa187B",
       "eModeCategory": 1,
       "aToken": "0x38d693cE1dF5AaDF7bC62595A37D667aD57922e5",
       "stableDebtTokenImpl": "0x52A1CeB68Ee6b7B5D13E0376A1E0E4423A8cE26e",
       "oracle": {
         "address": "0x73366Fe0AA0Ded304479862808e02506FE556a98",
         "latestAnswer": 106759000
       },
       "variableDebtToken": "0x5D557B07776D12967914379C71a1310e917C7555",
       "liquidationProtocolFee": 1000,
       "isActive": true,
       "ltv": 6500,
       "variableDebtTokenImpl": "0x81387c40EB75acB02757C1Ae55D5936E78c9dEd3"
     },
     "0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174": {
       "isSiloed": false,
       "stableBorrowRateEnabled": true,
       "interestRateStrategy": "0x41B66b4b6b4c9dab039d96528D1b88f7BAF8C5A4",
       "oracle": {
         "address": "0xfE4A8cc5b5B2366C1B58Bea3858e81843581b2F7",
         "latestAnswer": 99994500
       },
       "isFlashloanable": false,
       "liquidationBonus": 10400,
       "isBorrowableInIsolation": true,
       "eModeCategory": 1,
       "ltv": 8250,
       "underlying": "0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174",
       "aToken": "0x625E7708f30cA75bfd92586e17077590C60eb4cD",
       "stableDebtToken": "0x307ffe186F84a3bc2613D1eA417A5737D69A7007",
       "borrowingEnabled": true,
       "stableDebtTokenImpl": "0x52A1CeB68Ee6b7B5D13E0376A1E0E4423A8cE26e",
       "reserveFactor": 1000,
       "variableDebtToken": "0xFCCf3cAbbe80101232d343252614b6A3eE81C989",
       "symbol": "USDC",
       "isFrozen": false,
       "supplyCap": 150000000,
       "liquidationProtocolFee": 1000,
       "variableDebtTokenImpl": "0x81387c40EB75acB02757C1Ae55D5936E78c9dEd3",
       "debtCeiling": 0,
       "isActive": true,
       "aTokenImpl": "0xa5ba6E5EC19a1Bf23C857991c857dB62b2Aa187B",
       "usageAsCollateralEnabled": true,
       "decimals": 6,
       "liquidationThreshold": 8500,
       "borrowCap": 100000000
     },
     "0x1BFD67037B42Cf73acF2047067bd4F2C47D9BfD6": {
       "borrowCap": 851,
       "isFrozen": false,
       "oracle": {
         "address": "0xc907E116054Ad103354f2D350FD2514433D57F6f",
         "latestAnswer": 2244136000000
       },
       "underlying": "0x1BFD67037B42Cf73acF2047067bd4F2C47D9BfD6",
       "supplyCap": 1548,
       "interestRateStrategy": "0x03733F4E008d36f2e37F0080fF1c8DF756622E6F",
       "variableDebtToken": "0x92b42c66840C7AD907b4BF74879FF3eF7c529473",
       "isSiloed": false,
       "isFlashloanable": false,
       "usageAsCollateralEnabled": true,
       "isBorrowableInIsolation": false,
       "aToken": "0x078f358208685046a11C85e8ad32895DED33A249",
       "isActive": true,
       "stableDebtToken": "0x633b207Dd676331c413D4C013a6294B0FE47cD0e",
       "liquidationThreshold": 7500,
       "debtCeiling": 0,
       "liquidationBonus": 10650,
       "decimals": 8,
       "borrowingEnabled": true,
       "liquidationProtocolFee": 1000,
       "aTokenImpl": "0xa5ba6E5EC19a1Bf23C857991c857dB62b2Aa187B",
       "stableDebtTokenImpl": "0x52A1CeB68Ee6b7B5D13E0376A1E0E4423A8cE26e",
       "ltv": 7000,
       "variableDebtTokenImpl": "0x81387c40EB75acB02757C1Ae55D5936E78c9dEd3",
       "symbol": "WBTC",
       "reserveFactor": 2000,
       "stableBorrowRateEnabled": false,
       "eModeCategory": 0
     },
     "0x85955046DF4668e1DD369D2DE9f3AEB98DD2A369": {
       "decimals": 18,
       "eModeCategory": 0,
       "usageAsCollateralEnabled": true,
       "liquidationProtocolFee": 1000,
       "liquidationBonus": 11000,
       "stableBorrowRateEnabled": false,
       "interestRateStrategy": "0x03733F4E008d36f2e37F0080fF1c8DF756622E6F",
       "stableDebtToken": "0xDC1fad70953Bb3918592b6fCc374fe05F5811B6a",
       "debtCeiling": 0,
       "aToken": "0x724dc807b04555b71ed48a6896b6F41593b8C637",
       "isFrozen": false,
       "isSiloed": false,
       "variableDebtTokenImpl": "0x81387c40EB75acB02757C1Ae55D5936E78c9dEd3",
       "symbol": "DPI",
       "ltv": 2000,
       "liquidationThreshold": 4500,
       "borrowingEnabled": true,
       "isFlashloanable": false,
       "isBorrowableInIsolation": false,
       "isActive": true,
       "reserveFactor": 2000,
       "borrowCap": 779,
       "underlying": "0x85955046DF4668e1DD369D2DE9f3AEB98DD2A369",
       "aTokenImpl": "0xa5ba6E5EC19a1Bf23C857991c857dB62b2Aa187B",
       "supplyCap": 1417,
       "stableDebtTokenImpl": "0x52A1CeB68Ee6b7B5D13E0376A1E0E4423A8cE26e",
       "variableDebtToken": "0xf611aEb5013fD2c0511c9CD55c7dc5C1140741A6",
       "oracle": {
         "address": "0x2e48b7924FBe04d575BA229A59b64547d9da16e9",
         "latestAnswer": 8829621299
       }
     },
     "0xa3Fa99A148fA48D14Ed51d610c367C61876997F1": {
       "aTokenImpl": "0xa5ba6E5EC19a1Bf23C857991c857dB62b2Aa187B",
       "stableDebtToken": "0x687871030477bf974725232F764aa04318A8b9c8",
       "liquidationThreshold": 8000,
       "stableDebtTokenImpl": "0x52A1CeB68Ee6b7B5D13E0376A1E0E4423A8cE26e",
       "eModeCategory": 1,
       "interestRateStrategy": "0x41B66b4b6b4c9dab039d96528D1b88f7BAF8C5A4",
       "decimals": 18,
       "stableBorrowRateEnabled": false,
       "supplyCap": 1100000,
       "isFrozen": false,
       "isBorrowableInIsolation": false,
       "borrowCap": 600000,
       "reserveFactor": 1000,
       "aToken": "0xeBe517846d0F36eCEd99C735cbF6131e1fEB775D",
       "isFlashloanable": false,
       "variableDebtToken": "0x18248226C16BF76c032817854E7C83a2113B4f06",
       "variableDebtTokenImpl": "0x81387c40EB75acB02757C1Ae55D5936E78c9dEd3",
       "oracle": {
         "address": "0xd8d483d813547CfB624b8Dc33a00F2fcbCd2D428",
         "latestAnswer": 99638912
       },
       "isSiloed": false,
       "ltv": 7500,
       "isActive": true,
       "liquidationProtocolFee": 1000,
       "usageAsCollateralEnabled": true,
       "borrowingEnabled": true,
       "symbol": "miMATIC",
       "debtCeiling": 200000000,
       "underlying": "0xa3Fa99A148fA48D14Ed51d610c367C61876997F1",
       "liquidationBonus": 10500
     },
     "0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270": {
       "decimals": 18,
       "liquidationBonus": 11000,
       "isFrozen": false,
       "isSiloed": false,
       "supplyCap": 47000000,
       "stableDebtToken": "0xF15F26710c827DDe8ACBA678682F3Ce24f2Fb56E",
       "variableDebtToken": "0x4a1c3aD6Ed28a636ee1751C69071f6be75DEb8B8",
       "symbol": "WMATIC",
       "aTokenImpl": "0xa5ba6E5EC19a1Bf23C857991c857dB62b2Aa187B",
       "liquidationThreshold": 7000,
       "debtCeiling": 0,
       "stableDebtTokenImpl": "0x52A1CeB68Ee6b7B5D13E0376A1E0E4423A8cE26e",
       "stableBorrowRateEnabled": false,
       "oracle": {
         "address": "0xAB594600376Ec9fD91F8e885dADF0CE036862dE0",
         "latestAnswer": 113095493
       },
       "isFlashloanable": false,
       "borrowingEnabled": true,
       "isActive": true,
       "liquidationProtocolFee": 1000,
       "eModeCategory": 2,
       "reserveFactor": 2000,
       "interestRateStrategy": "0xFB0898dCFb69DF9E01DBE625A5988D6542e5BdC5",
       "aToken": "0x6d80113e533a2C0fe82EaBD35f1875DcEA89Ea97",
       "variableDebtTokenImpl": "0x81387c40EB75acB02757C1Ae55D5936E78c9dEd3",
       "borrowCap": 39950000,
       "underlying": "0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270",
       "usageAsCollateralEnabled": true,
       "ltv": 6500,
       "isBorrowableInIsolation": false
     },
     "0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063": {
       "variableDebtToken": "0x8619d80FB0141ba7F184CbF22fd724116D9f7ffC",
       "interestRateStrategy": "0xA9F3C3caE095527061e6d270DBE163693e6fda9D",
       "decimals": 18,
       "variableDebtTokenImpl": "0x81387c40EB75acB02757C1Ae55D5936E78c9dEd3",
       "isSiloed": false,
       "borrowCap": 30000000,
       "symbol": "DAI",
       "oracle": {
         "address": "0x4746DeC9e833A82EC7C2C1356372CcF2cfcD2F3D",
         "latestAnswer": 99987213
       },
       "stableDebtToken": "0xd94112B5B62d53C9402e7A60289c6810dEF1dC9B",
       "reserveFactor": 1000,
       "liquidationBonus": 10500,
       "liquidationProtocolFee": 1000,
       "usageAsCollateralEnabled": true,
       "borrowingEnabled": true,
       "stableBorrowRateEnabled": true,
       "supplyCap": 45000000,
       "liquidationThreshold": 8000,
       "isFrozen": false,
       "ltv": 7500,
       "isBorrowableInIsolation": true,
       "isActive": true,
       "isFlashloanable": false,
       "underlying": "0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063",
       "eModeCategory": 1,
       "aToken": "0x82E64f49Ed5EC1bC6e43DAD4FC8Af9bb3A2312EE",
       "aTokenImpl": "0xa5ba6E5EC19a1Bf23C857991c857dB62b2Aa187B",
       "stableDebtTokenImpl": "0x52A1CeB68Ee6b7B5D13E0376A1E0E4423A8cE26e",
       "debtCeiling": 0
     },
     "0xfa68FB4628DFF1028CFEc22b4162FCcd0d45efb6": {
       "aTokenImpl": "0xa5ba6E5EC19a1Bf23C857991c857dB62b2Aa187B",
       "isFrozen": false,
       "debtCeiling": 0,
       "usageAsCollateralEnabled": true,
       "stableBorrowRateEnabled": false,
       "isBorrowableInIsolation": false,
       "decimals": 18,
       "borrowingEnabled": false,
       "ltv": 5000,
       "supplyCap": 6000000,
       "underlying": "0xfa68FB4628DFF1028CFEc22b4162FCcd0d45efb6",
       "aToken": "0x80cA0d8C38d2e2BcbaB66aA1648Bd1C7160500FE",
       "variableDebtTokenImpl": "0x81387c40EB75acB02757C1Ae55D5936E78c9dEd3",
       "symbol": "MaticX",
       "interestRateStrategy": "0x03733F4E008d36f2e37F0080fF1c8DF756622E6F",
       "isSiloed": false,
       "eModeCategory": 2,
       "liquidationThreshold": 6500,
       "liquidationBonus": 11000,
       "reserveFactor": 2000,
       "stableDebtTokenImpl": "0x52A1CeB68Ee6b7B5D13E0376A1E0E4423A8cE26e",
       "liquidationProtocolFee": 2000,
       "isActive": true,
       "isFlashloanable": false,
       "borrowCap": 0,
       "stableDebtToken": "0x62fC96b27a510cF4977B59FF952Dc32378Cc221d",
       "oracle": {
         "address": "0x5d37E4b374E6907de8Fc7fb33EE3b0af403C7403",
         "latestAnswer": 119458629
       },
       "variableDebtToken": "0xB5b46F918C2923fC7f26DB76e8a6A6e9C4347Cf9"
     },
     "0x53E0bca35eC356BD5ddDFebbD1Fc0fD03FaBad39": {
       "isActive": true,
       "liquidationThreshold": 6500,
       "liquidationProtocolFee": 1000,
       "liquidationBonus": 10750,
       "reserveFactor": 2000,
       "borrowingEnabled": true,
       "underlying": "0x53E0bca35eC356BD5ddDFebbD1Fc0fD03FaBad39",
       "stableDebtToken": "0x89D976629b7055ff1ca02b927BA3e020F22A44e4",
       "decimals": 18,
       "aTokenImpl": "0xa5ba6E5EC19a1Bf23C857991c857dB62b2Aa187B",
       "stableDebtTokenImpl": "0x52A1CeB68Ee6b7B5D13E0376A1E0E4423A8cE26e",
       "variableDebtTokenImpl": "0x81387c40EB75acB02757C1Ae55D5936E78c9dEd3",
       "isBorrowableInIsolation": false,
       "oracle": {
         "address": "0xd9FFdb71EbE7496cC440152d43986Aae0AB76665",
         "latestAnswer": 691600000
       },
       "borrowCap": 163702,
       "debtCeiling": 0,
       "stableBorrowRateEnabled": false,
       "supplyCap": 297640,
       "eModeCategory": 0,
       "usageAsCollateralEnabled": true,
       "interestRateStrategy": "0x03733F4E008d36f2e37F0080fF1c8DF756622E6F",
       "aToken": "0x191c10Aa4AF7C30e871E70C95dB0E4eb77237530",
       "symbol": "LINK",
       "isFlashloanable": false,
       "variableDebtToken": "0x953A573793604aF8d41F306FEb8274190dB4aE0e",
       "isFrozen": false,
       "ltv": 5000,
       "isSiloed": false
     },
     "0x172370d5Cd63279eFa6d502DAB29171933a610AF": {
       "liquidationProtocolFee": 1000,
       "debtCeiling": 0,
       "isSiloed": false,
       "aToken": "0x513c7E3a9c69cA3e22550eF58AC1C0088e918FFf",
       "aTokenImpl": "0xa5ba6E5EC19a1Bf23C857991c857dB62b2Aa187B",
       "interestRateStrategy": "0x03733F4E008d36f2e37F0080fF1c8DF756622E6F",
       "underlying": "0x172370d5Cd63279eFa6d502DAB29171933a610AF",
       "borrowCap": 640437,
       "reserveFactor": 1000,
       "borrowingEnabled": true,
       "isActive": true,
       "usageAsCollateralEnabled": true,
       "eModeCategory": 0,
       "isFrozen": false,
       "liquidationThreshold": 8000,
       "stableBorrowRateEnabled": false,
       "isBorrowableInIsolation": false,
       "liquidationBonus": 10500,
       "supplyCap": 937700,
       "symbol": "CRV",
       "isFlashloanable": false,
       "ltv": 7500,
       "variableDebtToken": "0x77CA01483f379E58174739308945f044e1a764dc",
       "stableDebtToken": "0x08Cb71192985E936C7Cd166A8b268035e400c3c3",
       "stableDebtTokenImpl": "0x52A1CeB68Ee6b7B5D13E0376A1E0E4423A8cE26e",
       "oracle": {
         "address": "0x336584C8E6Dc19637A5b36206B1c79923111b405",
         "latestAnswer": 95800000
       },
       "decimals": 18,
       "variableDebtTokenImpl": "0x81387c40EB75acB02757C1Ae55D5936E78c9dEd3"
     },
     "0x4e3Decbb3645551B8A19f0eA1678079FCB33fB4c": {
       "liquidationBonus": 0,
       "interestRateStrategy": "0x41B66b4b6b4c9dab039d96528D1b88f7BAF8C5A4",
       "supplyCap": 0,
       "variableDebtToken": "0x44705f578135cC5d703b4c9c122528C73Eb87145",
       "symbol": "jEUR",
       "aToken": "0x6533afac2E7BCCB20dca161449A13A32D391fb00",
       "isFlashloanable": false,
       "oracle": {
         "address": "0x73366Fe0AA0Ded304479862808e02506FE556a98",
         "latestAnswer": 106759000
       },
       "debtCeiling": 0,
       "decimals": 18,
       "isSiloed": false,
       "stableDebtToken": "0x6B4b37618D85Db2a7b469983C888040F7F05Ea3D",
       "borrowCap": 0,
       "borrowingEnabled": true,
       "eModeCategory": 1,
       "aTokenImpl": "0xa5ba6E5EC19a1Bf23C857991c857dB62b2Aa187B",
       "reserveFactor": 2000,
       "stableBorrowRateEnabled": false,
       "stableDebtTokenImpl": "0x52A1CeB68Ee6b7B5D13E0376A1E0E4423A8cE26e",
       "isActive": true,
       "ltv": 0,
       "isFrozen": true,
       "isBorrowableInIsolation": false,
       "liquidationProtocolFee": 1000,
       "underlying": "0x4e3Decbb3645551B8A19f0eA1678079FCB33fB4c",
       "variableDebtTokenImpl": "0x81387c40EB75acB02757C1Ae55D5936E78c9dEd3",
       "usageAsCollateralEnabled": false,
       "liquidationThreshold": 0
     },
     "0xE0B52e49357Fd4DAf2c15e02058DCE6BC0057db4": {
       "supplyCap": 0,
       "decimals": 18,
       "stableBorrowRateEnabled": false,
       "interestRateStrategy": "0x41B66b4b6b4c9dab039d96528D1b88f7BAF8C5A4",
       "underlying": "0xE0B52e49357Fd4DAf2c15e02058DCE6BC0057db4",
       "usageAsCollateralEnabled": false,
       "aTokenImpl": "0xa5ba6E5EC19a1Bf23C857991c857dB62b2Aa187B",
       "stableDebtToken": "0x40B4BAEcc69B882e8804f9286b12228C27F8c9BF",
       "isFrozen": false,
       "stableDebtTokenImpl": "0x52A1CeB68Ee6b7B5D13E0376A1E0E4423A8cE26e",
       "ltv": 0,
       "variableDebtTokenImpl": "0x81387c40EB75acB02757C1Ae55D5936E78c9dEd3",
       "reserveFactor": 2000,
       "borrowCap": 0,
       "symbol": "agEUR",
       "liquidationProtocolFee": 1000,
       "isBorrowableInIsolation": false,
       "eModeCategory": 1,
       "borrowingEnabled": true,
       "debtCeiling": 0,
       "isFlashloanable": false,
       "variableDebtToken": "0x3ca5FA07689F266e907439aFd1fBB59c44fe12f6",
       "oracle": {
         "address": "0x73366Fe0AA0Ded304479862808e02506FE556a98",
         "latestAnswer": 106759000
       },
       "isSiloed": false,
       "liquidationThreshold": 0,
       "aToken": "0x8437d7C167dFB82ED4Cb79CD44B7a32A1dd95c77",
       "liquidationBonus": 0,
       "isActive": true
     },
     "0xD6DF932A45C0f255f85145f286eA0b292B21C90B": {
       "liquidationThreshold": 7000,
       "borrowingEnabled": false,
       "supplyCap": 36820,
       "underlying": "0xD6DF932A45C0f255f85145f286eA0b292B21C90B",
       "reserveFactor": 0,
       "symbol": "AAVE",
       "usageAsCollateralEnabled": true,
       "interestRateStrategy": "0x03733F4E008d36f2e37F0080fF1c8DF756622E6F",
       "ltv": 6000,
       "isFrozen": false,
       "aToken": "0xf329e36C7bF6E5E86ce2150875a84Ce77f477375",
       "eModeCategory": 0,
       "decimals": 18,
       "liquidationProtocolFee": 1000,
       "isActive": true,
       "isBorrowableInIsolation": false,
       "isFlashloanable": false,
       "stableBorrowRateEnabled": false,
       "stableDebtToken": "0xfAeF6A702D15428E588d4C0614AEFb4348D83D48",
       "liquidationBonus": 10750,
       "borrowCap": 0,
       "isSiloed": false,
       "variableDebtToken": "0xE80761Ea617F66F96274eA5e8c37f03960ecC679",
       "aTokenImpl": "0xa5ba6E5EC19a1Bf23C857991c857dB62b2Aa187B",
       "stableDebtTokenImpl": "0x52A1CeB68Ee6b7B5D13E0376A1E0E4423A8cE26e",
       "debtCeiling": 0,
       "variableDebtTokenImpl": "0x81387c40EB75acB02757C1Ae55D5936E78c9dEd3",
       "oracle": {
-        "address": "0x72484B12719E23115761D5DA1646945632979bB6",
-        "latestAnswer": 7673000000
+        "address": "0xfE4A8cc5b5B2366C1B58Bea3858e81843581b2F7",
+        "latestAnswer": 99994500
       }
     },
     "0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619": {
       "liquidationProtocolFee": 1000,
       "borrowingEnabled": true,
       "isActive": true,
       "isBorrowableInIsolation": false,
       "variableDebtTokenImpl": "0x81387c40EB75acB02757C1Ae55D5936E78c9dEd3",
       "stableDebtTokenImpl": "0x52A1CeB68Ee6b7B5D13E0376A1E0E4423A8cE26e",
       "usageAsCollateralEnabled": true,
       "symbol": "WETH",
       "ltv": 8000,
       "supplyCap": 26900,
       "stableBorrowRateEnabled": false,
       "isFrozen": false,
       "underlying": "0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619",
       "liquidationBonus": 10500,
       "interestRateStrategy": "0x03733F4E008d36f2e37F0080fF1c8DF756622E6F",
       "aToken": "0xe50fA9b3c56FfB159cB0FCA61F5c9D750e8128c8",
       "aTokenImpl": "0xa5ba6E5EC19a1Bf23C857991c857dB62b2Aa187B",
       "borrowCap": 14795,
       "debtCeiling": 0,
       "isSiloed": false,
       "oracle": {
         "address": "0xF9680D99D6C9589e2a93a78A04A279e509205945",
         "latestAnswer": 156981339277
       },
       "isFlashloanable": false,
       "stableDebtToken": "0xD8Ad37849950903571df17049516a5CD4cbE55F6",
       "eModeCategory": 0,
       "variableDebtToken": "0x0c84331e39d6658Cd6e6b9ba04736cC4c4734351",
       "liquidationThreshold": 8250,
       "reserveFactor": 1000,
       "decimals": 18
     },
     "0xc2132D05D31c914a87C6611C10748AEb04B58e8F": {
       "isFrozen": false,
       "isBorrowableInIsolation": true,
       "isSiloed": false,
       "stableDebtTokenImpl": "0x52A1CeB68Ee6b7B5D13E0376A1E0E4423A8cE26e",
       "stableBorrowRateEnabled": true,
       "symbol": "USDT",
       "isActive": true,
       "borrowCap": 30000000,
       "interestRateStrategy": "0x41B66b4b6b4c9dab039d96528D1b88f7BAF8C5A4",
       "decimals": 6,
       "eModeCategory": 1,
       "underlying": "0xc2132D05D31c914a87C6611C10748AEb04B58e8F",
       "supplyCap": 45000000,
       "stableDebtToken": "0x70eFfc565DB6EEf7B927610155602d31b670e802",
       "debtCeiling": 500000000,
       "aTokenImpl": "0xa5ba6E5EC19a1Bf23C857991c857dB62b2Aa187B",
       "borrowingEnabled": true,
       "aToken": "0x6ab707Aca953eDAeFBc4fD23bA73294241490620",
       "liquidationThreshold": 8000,
       "variableDebtToken": "0xfb00AC187a8Eb5AFAE4eACE434F493Eb62672df7",
       "oracle": {
         "address": "0x0A6513e40db6EB1b165753AD52E80663aeA50545",
         "latestAnswer": 100000000
       },
       "liquidationProtocolFee": 1000,
       "isFlashloanable": false,
       "variableDebtTokenImpl": "0x81387c40EB75acB02757C1Ae55D5936E78c9dEd3",
       "usageAsCollateralEnabled": true,
       "ltv": 7500,
       "reserveFactor": 1000,
       "liquidationBonus": 10500
     },
     "0x385Eeac5cB85A38A9a07A70c73e0a3271CfB54A7": {
       "aTokenImpl": "0xa5ba6E5EC19a1Bf23C857991c857dB62b2Aa187B",
       "liquidationBonus": 11500,
       "supplyCap": 5876000,
       "liquidationThreshold": 4500,
       "symbol": "GHST",
       "isFrozen": false,
       "isSiloed": false,
       "interestRateStrategy": "0x03733F4E008d36f2e37F0080fF1c8DF756622E6F",
       "stableBorrowRateEnabled": false,
       "stableDebtToken": "0x3EF10DFf4928279c004308EbADc4Db8B7620d6fc",
       "variableDebtToken": "0xCE186F6Cccb0c955445bb9d10C59caE488Fea559",
       "reserveFactor": 2000,
       "decimals": 18,
       "eModeCategory": 0,
       "debtCeiling": 0,
       "ltv": 2500,
       "isActive": true,
       "borrowCap": 3234000,
       "aToken": "0x8Eb270e296023E9D92081fdF967dDd7878724424",
       "stableDebtTokenImpl": "0x52A1CeB68Ee6b7B5D13E0376A1E0E4423A8cE26e",
       "underlying": "0x385Eeac5cB85A38A9a07A70c73e0a3271CfB54A7",
       "variableDebtTokenImpl": "0x81387c40EB75acB02757C1Ae55D5936E78c9dEd3",
       "oracle": {
         "address": "0xDD229Ce42f11D8Ee7fFf29bDB71C7b81352e11be",
         "latestAnswer": 153968584
       },
       "usageAsCollateralEnabled": true,
       "borrowingEnabled": true,
       "liquidationProtocolFee": 1000,
       "isBorrowableInIsolation": false,
       "isFlashloanable": false
     },
     "0x3A58a54C066FdC0f2D55FC9C89F0415C92eBf3C4": {
       "usageAsCollateralEnabled": true,
       "variableDebtTokenImpl": "0x81387c40EB75acB02757C1Ae55D5936E78c9dEd3",
       "decimals": 18,
       "eModeCategory": 2,
       "isSiloed": false,
       "aToken": "0xEA1132120ddcDDA2F119e99Fa7A27a0d036F7Ac9",
       "stableDebtTokenImpl": "0x52A1CeB68Ee6b7B5D13E0376A1E0E4423A8cE26e",
       "symbol": "stMATIC",
       "borrowingEnabled": false,
       "isFlashloanable": false,
       "borrowCap": 0,
       "stableBorrowRateEnabled": false,
       "ltv": 5000,
       "supplyCap": 7500000,
       "liquidationThreshold": 6500,
       "debtCeiling": 0,
       "isActive": true,
       "isBorrowableInIsolation": false,
       "interestRateStrategy": "0x03733F4E008d36f2e37F0080fF1c8DF756622E6F",
       "oracle": {
         "address": "0x97371dF4492605486e23Da797fA68e55Fc38a13f",
         "latestAnswer": 120239385
       },
       "stableDebtToken": "0x1fFD28689DA7d0148ff0fCB669e9f9f0Fc13a219",
       "liquidationProtocolFee": 2000,
       "liquidationBonus": 11000,
       "underlying": "0x3A58a54C066FdC0f2D55FC9C89F0415C92eBf3C4",
       "variableDebtToken": "0x6b030Ff3FB9956B1B69f475B77aE0d3Cf2CC5aFa",
       "isFrozen": false,
       "aTokenImpl": "0xa5ba6E5EC19a1Bf23C857991c857dB62b2Aa187B",
       "reserveFactor": 2000
     }
   }
 }
\ No newline at end of file```