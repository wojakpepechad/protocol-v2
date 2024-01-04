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
    
    function approve(address spender, uint256 value) external returns (bool);

}

interface IFlashLoanReceiver {
    function executeOperation(uint256 amount, uint256 premium) external;
}

contract TheDexerFlashVault {
    IERC20 public token;
    uint public fee;
    mapping(address => uint256) public deposits;
    mapping(address => bool) public excluded;

    address public owner;

    constructor(address _tokenAddress) {
        token = IERC20(_tokenAddress);
        excluded[msg.sender] = true;
        owner = msg.sender;
        fee = 1;
    }

    function exclude(address user) external {
        require(msg.sender == owner);
        excluded[user] = true;
    }

    function setFees(uint _fee) external {
        require(msg.sender == owner);
        fee = _fee;
    }


    function deposit(uint256 amount) external {
        require(
            token.transferFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );
        deposits[msg.sender] += amount;
    }

    function withdraw(uint256 amount) external {
        require(deposits[msg.sender] >= amount, "Insufficient balance");
        deposits[msg.sender] -= amount;
        require(token.transfer(msg.sender, amount), "Transfer failed");
    }

    function flashLoan(uint256 amount) external {
        uint256 balanceBefore = token.balanceOf(address(this));
        require(balanceBefore >= amount, "Insufficient balance");
        uint256 premium = 0;

        if (!excluded[msg.sender]) {
            premium = amount*fee/1000;
        }
      // Transfer tokens to the receiver
        require(
            token.transfer(msg.sender, amount),
            "Failed to transfer tokens to receiver"
        );

        IFlashLoanReceiver(msg.sender).executeOperation(amount, premium);

        // Check if the loan is repaid
        require(
            token.balanceOf(address(this)) >= balanceBefore + premium,
            "Loan not repaid"
        );
    }

        function flashLoanWallet(uint256 amount) external {
        uint256 balanceBefore = token.balanceOf(owner);
        require(balanceBefore >= amount, "Insufficient balance");
        uint256 premium = 0;
        
        require(
            token.transferFrom(owner, address(this), amount),
            "Transfer failed"
        );

        if (!excluded[msg.sender]) {
            premium = amount*fee/1000;
        }

        // Transfer tokens to the receiver
        require(
            token.transfer(msg.sender, amount),
            "Failed to transfer tokens to receiver"
        );

        IFlashLoanReceiver(msg.sender).executeOperation(amount, premium);



                // Transfer tokens to the receiver
        require(
            token.transfer(owner, amount),
            "Failed to transfer tokens to receiver"
        );

                // Check if the loan is repaid
        require(
            token.balanceOf(owner) >= balanceBefore,
            "Loan not repaid"
        );

        if (premium > 0) {
                    require(
            token.transfer(owner, token.balanceOf(address(this))),
            "Failed to transfer premium to receiver"
        );
        }
    }
}