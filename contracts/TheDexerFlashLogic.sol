// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

interface IFlashLoanReceiver {
    function executeOperation(uint256 amount, uint256 premium) external;
}

interface ITheDexerFlashVault {
    function flashLoan(uint256 amount) external;
    function flashLoanWallet(uint256 amount) external;
}

contract TheDexerFlashLogic is IFlashLoanReceiver {
    event FlashLoanExecuted(uint256 amount, address sender);

    ITheDexerFlashVault public flashVault;
    IERC20 public token;

    event FlashLoanPerformed(uint256 amount, address sender);

    constructor(address _flashVaultAddress, address _token) {
        flashVault = ITheDexerFlashVault(_flashVaultAddress);
        token = IERC20(_token);
    }

    function executeOperation(uint256 amount, uint256 premium) external override {
        emit FlashLoanExecuted(amount, msg.sender);

        // Ensure only the flashVault calls this function
        require(
            msg.sender == address(flashVault),
            "Caller is not the flashVault"
        );

        // Flash loan logic here ...

        // Calculate repayment amount (this includes any fees)
        uint256 amountToReturn = amount + premium; // Update with the correct amount

        // Transfer the funds back to the vault
        require(
            token.transfer(address(flashVault), amountToReturn),
            "Failed to repay loan"
        );

        emit FlashLoanPerformed(amount, msg.sender);
    }

    function initiateFlashLoan(uint256 amount) public {
        flashVault.flashLoan(amount);
    }

    function initiateFlashLoanWallet(uint256 amount) public {
        flashVault.flashLoanWallet(amount);
    }
}
