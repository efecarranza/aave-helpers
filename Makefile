# include .env file and export its env vars
# (-include to ignore error if it does not exist)
-include .env

# deps
update:; forge update

# Build & test
build  :; forge build
test   :; forge test -vvv
test-gauntlet-strategies-update:; forge test -vvv --match-path src/test/AaveV3ConfigEngineTest.t.sol --gas-report


# Scripts
deploy-engine-opt :;  forge script script/AaveV3ConfigEngine.s.sol:DeployEngineOpt --rpc-url optimism --broadcast --legacy --ledger --mnemonic-indexes ${MNEMONIC_INDEX} --sender ${LEDGER_SENDER} --verify --etherscan-api-key ${ETHERSCAN_API_KEY_OPTIMISM} -vvvv
deploy-engine-arb :;  forge script script/AaveV3ConfigEngine.s.sol:DeployEngineArb --rpc-url arbitrum --broadcast --legacy --ledger --mnemonic-indexes ${MNEMONIC_INDEX} --sender ${LEDGER_SENDER} --verify --etherscan-api-key ${ETHERSCAN_API_KEY_ARBITRUM} -vvvv
deploy-engine-pol :;  forge script script/AaveV3ConfigEngine.s.sol:DeployEnginePol --rpc-url polygon --broadcast --legacy --ledger --mnemonic-indexes ${MNEMONIC_INDEX} --sender ${LEDGER_SENDER} --verify --etherscan-api-key ${ETHERSCAN_API_KEY_POLYGON} -vvvv
deploy-engine-ava :; forge script script/AaveV3ConfigEngine.s.sol:DeployEngineAva --rpc-url avalanche --broadcast --legacy --ledger --mnemonic-indexes ${MNEMONIC_INDEX} --sender ${LEDGER_SENDER} --verify --etherscan-api-key ${ETHERSCAN_API_KEY_AVALANCHE} -vvvv
deploy-rates-factory-eth :; forge script script/V3RateStrategyFactory.s.sol:DeployRatesFactoryEth --rpc-url mainnet --broadcast --legacy --ledger --mnemonic-indexes ${MNEMONIC_INDEX} --sender ${LEDGER_SENDER} --verify --etherscan-api-key ${ETHERSCAN_API_KEY_MAINNET} -vvvv
deploy-rates-factory-pol :; forge script script/V3RateStrategyFactory.s.sol:DeployRatesFactoryPol --rpc-url polygon --broadcast --legacy --ledger --mnemonic-indexes ${MNEMONIC_INDEX} --sender ${LEDGER_SENDER} --verify --etherscan-api-key ${ETHERSCAN_API_KEY_POLYGON} -vvvv
deploy-rates-factory-opt :; forge script script/V3RateStrategyFactory.s.sol:DeployRatesFactoryOpt --rpc-url optimism --broadcast --legacy --ledger --mnemonic-indexes ${MNEMONIC_INDEX} --sender ${LEDGER_SENDER} --verify --etherscan-api-key ${ETHERSCAN_API_KEY_OPTIMISM} -vvvv
deploy-rates-factory-arb :; forge script script/V3RateStrategyFactory.s.sol:DeployRatesFactoryArb --rpc-url arbitrum --broadcast --legacy --ledger --mnemonic-indexes ${MNEMONIC_INDEX} --sender ${LEDGER_SENDER} --verify --etherscan-api-key ${ETHERSCAN_API_KEY_ARBITRUM} -vvvv
deploy-rates-factory-ava :; forge script script/V3RateStrategyFactory.s.sol:DeployRatesFactoryAva --rpc-url avalanche --broadcast --legacy --ledger --mnemonic-indexes ${MNEMONIC_INDEX} --sender ${LEDGER_SENDER} --verify --etherscan-api-key ${ETHERSCAN_API_KEY_AVALANCHE} -vvvv

# Utilities
download :; cast etherscan-source --chain ${chain} -d src/etherscan/${chain}_${address} ${address}
git-diff :
	@mkdir -p diffs
	@printf '%s\n%s\n%s\n' "\`\`\`diff" "$$(git diff --no-index --diff-algorithm=patience --ignore-space-at-eol ${before} ${after})" "\`\`\`" > diffs/${out}.md
