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
  function executeOperation(
    address[] calldata tokens,
    uint256[] calldata amounts,
    uint256[] calldata premiums
  ) external;
}

contract TheDexerFlashVault {
  uint256 public fee;
  mapping(address => bool) public excluded;

  address public owner;

  constructor() {
    excluded[msg.sender] = true;
    owner = msg.sender;
    fee = 1;
  }

  modifier onlyOwner() {
    require(msg.sender == owner, 'Not the owner');
    _;
  }

  function exclude(address user) external onlyOwner {
    excluded[user] = true;
  }

  function setFees(uint256 _fee) external onlyOwner {
    fee = _fee;
  }

  function deposit(address tokenAddress, uint256 amount) external {
    IERC20 token = IERC20(tokenAddress);
    require(token.transferFrom(msg.sender, address(this), amount), 'Transfer failed');
  }

  function withdraw(address tokenAddress, uint256 amount) external onlyOwner {
    IERC20 token = IERC20(tokenAddress);
    require(token.transfer(msg.sender, amount), 'Transfer failed');
  }

  function flashLoan(address[] calldata tokens, uint256[] calldata amounts) external {
    require(tokens.length == amounts.length, 'Mismatched tokens and amounts');

    uint256[] memory premiums = new uint256[](tokens.length);
    uint256[] memory balancesBefore = new uint256[](tokens.length); // Store initial balances

    // Transfer out tokens and record balances before the loan
    for (uint256 i = 0; i < tokens.length; i++) {
      address tokenAddress = tokens[i];
      uint256 amount = amounts[i];
      IERC20 token = IERC20(tokenAddress);

      balancesBefore[i] = token.balanceOf(address(this));
      require(balancesBefore[i] >= amount, 'Insufficient balance');

      premiums[i] = !excluded[msg.sender] ? (amount * fee) / 1000 : 0;

      require(token.transfer(msg.sender, amount), 'Failed to transfer tokens');
    }

    // Execute operation with the loaned tokens
    IFlashLoanReceiver(msg.sender).executeOperation(tokens, amounts, premiums);

    // Check if loans are repaid
    for (uint256 i = 0; i < tokens.length; i++) {
      address tokenAddress = tokens[i];
      IERC20 token = IERC20(tokenAddress);

      // Use the stored balance before to check repayment
      uint256 requiredBalanceAfter = balancesBefore[i] + premiums[i];
      require(token.balanceOf(address(this)) >= requiredBalanceAfter, 'Loan not repaid');
    }
  }

  function flashLoanWallet(address[] calldata tokens, uint256[] calldata amounts) external {
    require(tokens.length == amounts.length, 'Mismatched tokens and amounts');

    uint256[] memory premiums = new uint256[](tokens.length);
    uint256[] memory balancesBefore = new uint256[](tokens.length);

    // Transfer tokens from the owner to the borrower and record the initial balances
    for (uint256 i = 0; i < tokens.length; i++) {
      address tokenAddress = tokens[i];
      uint256 amount = amounts[i];
      IERC20 token = IERC20(tokenAddress);

      balancesBefore[i] = token.balanceOf(address(this));
      premiums[i] = !excluded[msg.sender] ? (amount * fee) / 1000 : 0;

      require(token.transferFrom(owner, address(this), amount), 'Transfer failed');
      require(token.transfer(msg.sender, amount), 'Failed to transfer tokens');
    }

    // Execute the borrower's operations with the loaned tokens
    IFlashLoanReceiver(msg.sender).executeOperation(tokens, amounts, premiums);

    // Check if the loans are repaid and transfer premiums to the owner
    for (uint256 i = 0; i < tokens.length; i++) {
      IERC20 token = IERC20(tokens[i]);
      uint256 requiredBalanceAfter = balancesBefore[i] + premiums[i];
      require(token.balanceOf(address(this)) >= requiredBalanceAfter, 'Loan not repaid');

      if (premiums[i] > 0) {
        require(token.transfer(owner, requiredBalanceAfter), 'Failed to transfer premium');
      }
    }
  }
}
