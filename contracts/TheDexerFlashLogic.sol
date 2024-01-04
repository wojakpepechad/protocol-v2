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
  function flashLoan(address[] calldata tokens, uint256[] calldata amounts) external;

  function flashLoanWallet(address[] calldata tokens, uint256[] calldata amounts) external;
}

 library InputSingle {
	 struct ExactInputSingleParams {
		 address tokenIn;
		 address tokenOut;
		 uint24 fee;
		 address recipient;
		 uint256 amountIn;
		 uint256 amountOutMinimum;
		 uint160 sqrtPriceLimitX96;
	 }
	 struct ExactInputParams {
		 bytes path;
		 address recipient;
		 uint256 amountIn;
		 uint256 amountOutMinimum;
	 }
 }
 
 interface ISwapRouter {
	 function exactInputSingle(
		 InputSingle.ExactInputSingleParams calldata params
	 ) external;
	 
	 function exactInput(
		 InputSingle.ExactInputParams calldata params
	 ) external returns (uint256 amountOut);
 }
 
 interface IFlashLender {
	 function flashLoan(
		 address receiverAddress,
		 address[] calldata assets,
		 uint256[] calldata amounts,
		 uint256[] calldata modes,
		 address onBehalfOf,
		 bytes calldata params,
		 uint16 referralCode
	 ) external;
 }
 


contract TheDexerFlashLogic is IFlashLoanReceiver {


  	error NotCaller();
	error FlashloanFailed();
	error MaximumSteps();
	uint256 MAX_INT =
	0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
	
	uint24 private constant poolFee = 100;
	uint24 private constant poolFee2 = 100;
	uint72 steps;
	address payable owner;
	
	address payable client;
	address private token0;
	address private token1;
	address private token2;
	address private flashloanPool;
	
  ITheDexerFlashVault public flashVault;

	ISwapRouter router;
	IFlashLender lender;
	
	mapping(address => bool) caller;

	event FlashLoanPerformed(uint256 amount, address sender);
  event FlashLoanExecuted(uint256 amount, address sender);

	modifier onlyOwner() {
		require(
			msg.sender == owner,
		  "Only the contract owner can call this function"
		);
		_;
	}
	
	modifier onlyCaller() {
		if (!caller[msg.sender]) revert NotCaller();
		_;
	}
	
	constructor(address _flashVaultAddress) {
    flashVault = ITheDexerFlashVault(_flashVaultAddress);
		owner = payable(msg.sender);
		token0 = 0x765DE816845861e75A25fCA122bb6898B8B1282a;
		token1 = 0x37f750B7cC259A2f741AF45294f6a16572CF5cAd;
		token2 = 0x471EcE3750Da237f93B8E339c536989b8978a438;
		router = ISwapRouter(0x5615CDAb10dc425a742d643d949a7F474C01abc4);
		flashloanPool = address(0x970b12522CA9b4054807a2c5B736149a5BE6f670);
		lender = IFlashLender(flashloanPool);
		IERC20(token0).approve(address(router), MAX_INT);
		IERC20(token1).approve(address(router), MAX_INT);
		IERC20(token2).approve(address(router), MAX_INT);
	}
	
	function withdraw(address _tokenAddress) external onlyOwner {
		IERC20 token = IERC20(_tokenAddress);
		token.transfer(msg.sender, token.balanceOf(address(this)));
	}
	
	function execute(uint256 _amount, uint8 _steps) external onlyCaller {
		if (_steps > 10) revert MaximumSteps();
		steps = _steps;
		client = payable(msg.sender);
		
		address[] memory assets = new address[](1);
		assets[0] = token0;
		
		uint256[] memory amounts = new uint256[](1);
		amounts[0] = _amount;
		
    flashVault.flashLoan(tokens, amounts);

	}
	
	function setCaller(address _caller) public onlyOwner {
		caller[_caller] = true;
	}
	
	function removeCaller(address _caller) public onlyOwner {
		caller[_caller] = false;
	}
	
	function _transferOwnership(address newOwner) public virtual onlyOwner {
		owner = payable(newOwner);
	}
	

  function executeOperation(
    address[] calldata _tokens,
    uint256[] calldata _amounts,
    uint256[] calldata _premiums
  ) external override {
    require(msg.sender == address(flashVault), 'Caller is not the flashVault');

    for (uint256 i = 0; i < _tokens.length; i++) {
      address tokenAddress = _tokens[i];
      uint256 amount = _amounts[i];
      uint256 premium = _premiums[i];

      emit FlashLoanExecuted(amount, tokenAddress);

      // Flash loan logic for each token here...

      // Repayment calculation for each token
      uint256 amountToReturn = amount + premium;

      // Ensure the contract has approval to transfer the tokens
      require(
        IERC20(tokenAddress).transfer(address(flashVault), amountToReturn),
        'Failed to repay loan'
      );

      emit FlashLoanPerformed(amount, tokenAddress);
    }
  }

    function initiateFlashLoan(address[] calldata tokens, uint256[] calldata amounts) public {
        flashVault.flashLoan(tokens, amounts);
    }

    function initiateFlashLoanWallet(address[] calldata tokens, uint256[] calldata amounts) public {
        flashVault.flashLoanWallet(tokens, amounts);
    }

  function _exactInputParams(
    uint256 amountIn,
    address tokenIn,
    address tokenOut
  ) internal {
    InputSingle.ExactInputSingleParams memory params = InputSingle.ExactInputSingleParams({
      tokenIn: tokenIn,
      tokenOut: tokenOut,
      fee: poolFee,
      recipient: address(this),
      amountIn: amountIn,
      amountOutMinimum: 0,
      sqrtPriceLimitX96: 0
    });
    router.exactInputSingle(params);
  }

  function _multihopParams(
    uint256 amountIn,
    address tokenIn,
    address tokenOut,
    uint24 fee,
    uint8 _steps
  ) internal {
    bytes memory path = getSwapPath(_steps, tokenIn, tokenOut, fee, poolFee2, token2);
    InputSingle.ExactInputParams memory params = InputSingle.ExactInputParams({
      path: path,
      recipient: address(this),
      amountIn: amountIn,
      amountOutMinimum: 0
    });
    router.exactInput(params);
  }

  function getSwapPath(
    uint8 _steps,
    address tokenIn,
    address tokenOut,
    uint24 fee,
    uint24 fee2,
    address tokenOut2
  ) internal pure returns (bytes memory path) {
    if (_steps == 2) {
      bytes memory _path1 = abi.encodePacked(
        tokenIn,
        fee,
        tokenOut,
        fee,
        tokenIn,
        fee2,
        tokenOut2,
        fee2,
        tokenIn
      );
      bytes memory _path2 = abi.encodePacked(
        fee,
        tokenOut,
        fee,
        tokenIn,
        fee2,
        tokenOut2,
        fee2,
        tokenIn
      );
      path = bytes.concat(_path1, _path2);
    }
    if (_steps == 5) {
      bytes memory _path1 = abi.encodePacked(
        tokenIn,
        fee,
        tokenOut,
        fee,
        tokenIn,
        fee2,
        tokenOut2,
        fee2,
        tokenIn
      );
      bytes memory _path2 = abi.encodePacked(
        fee,
        tokenOut,
        fee,
        tokenIn,
        fee2,
        tokenOut2,
        fee2,
        tokenIn
      );
      path = bytes.concat(_path1, _path2, _path2, _path2, _path2);
    }
  }
}
