// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IFinanceSteward {
    
    event BudgetUpdate(address indexed token, uint newAmount);

    /// Steward Actions
    function depositV3(address reserve, uint amount) external;
    function migrateV2toV3(address reserve, uint amount) external;
    function withdrawV2andSwap(address reserve, uint amount, address buyToken) external;
    function withdrawV3andSwap(address reserve, uint amount, address buyToken) external;
    function tokenSwap(address sellToken, uint256 amount, address buyToken) external;

    /// Controlled Actions
    function approve(address token, address to, uint256 amount) external;
    function transfer(address token, address to, uint256 amount) external;
    function createStream(address token, address to, uint256 amount, uint256 duration) external;
    function cancelStream(uint256 streamId) external;

    /// DAO Actions
    function increaseBudget(address token, uint256 amount) external;
    function decreaseBudget(address token, uint256 amount) external;
    function setSwappableToken(address token, address priceFeedUSD) external;
    function setWhitelistedReceiver(address to) external;
    function setMinimumBalanceShield(address token, uint amount) external;
}
