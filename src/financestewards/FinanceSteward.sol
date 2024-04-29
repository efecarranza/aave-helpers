// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from 'solidity-utils/contracts/oz-common/interfaces/IERC20.sol';
import {OwnableWithGuardian} from 'solidity-utils/contracts/access-control/OwnableWithGuardian.sol';

import {IFinanceSteward} from "./IFinanceSteward.sol";

contract FinanceSteward is OwnableWithGuardian, IFinanceSteward {
    constructor(address _owner, address _guardian) {
        _transferOwnership(_owner);
        _updateGuardian(_guardian);
    }

    /// Steward Actions

    function migrateV2toV3() external onlyOwnerOrGuardian {
        
    }

    function transfer(address token, address to, uint256 amount) external onlyOwnerOrGuardian {

    }

    function createStream(address token, address to, uint256 amount, uint256 duration) external onlyOwnerOrGuardian {

    }

    /// DAO Actions

    function setBudget(address token, uint256 amount) external onlyOwner {

    }

    function setSwappableToken(address token) external onlyOwner {

    }

    function setApprovedReceiver(address to) external onlyOwner {

    }
}
