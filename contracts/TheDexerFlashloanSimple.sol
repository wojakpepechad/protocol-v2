// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.6.12;

import {SafeMath} from '../../dependencies/openzeppelin/contracts/SafeMath.sol';
import {IERC20} from '../../dependencies/openzeppelin/contracts/IERC20.sol';

import {SafeERC20} from '../../dependencies/openzeppelin/contracts/SafeERC20.sol';
import {ILendingPoolAddressesProvider} from '../../interfaces/ILendingPoolAddressesProvider.sol';

contract TheDexerFlashloanSimple {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;


    event ExecutedWithFail(address[] _assets, uint256[] _amounts, uint256[] _premiums);
    event ExecutedWithSuccess(address[] _assets, uint256[] _amounts, uint256[] _premiums);
    event FlashLoanReceived(address[] assets, uint256[] amounts, uint256[] premiums);

    bool _failExecution;
    bool _simulateEOA;

    constructor(address tokenPool) public {}

    function setFailExecutionTransfer(bool fail) public {
        _failExecution = fail;
    }

    function setSimulateEOA(bool flag) public {
        _simulateEOA = flag;
    }

    function executeOperation(
        address[] memory assets,
        uint256[] memory amounts,
        uint256[] memory premiums,
        address initiator,
        bytes memory params
    ) public override returns (bool) {
        params; // Additional parameters can be processed here if needed
        emit FlashLoanReceived(assets, amounts, premiums);

        if (_failExecution) {
            emit ExecutedWithFail(assets, amounts, premiums);
            return !_simulateEOA;
        }

        for (uint256 i = 0; i < assets.length; i++) {
            // Assuming the contract has enough allowance
            // Transfer the amount from the initiator to this contract
            IERC20(assets[i]).safeTransferFrom(initiator, address(this), amounts[i]);

            // Process your logic here
            // ...

            // Return the funds (loan amount plus premium)
            uint256 amountToReturn = amounts[i].add(premiums[i]);
            IERC20(assets[i]).transfer(tokenPool, amountToReturn);
        }

        emit ExecutedWithSuccess(assets, amounts, premiums);
        return true;
    }
}
