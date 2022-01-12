// SPDX-License-Identifier: UNLICENSED
pragma solidity ^ 0.8.0;

import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';

interface IUniswapRouter is ISwapRouter {
    function refundETH() external payable;
}

contract Subscription{
    
    IUniswapRouter public constant swapRouter = IUniswapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);
    mapping(address => bool) public subscriptions;
    uint256 price;
    
    address private owner;
    address private constant DAI = 0xc7AD46e0b8a400Bb3C915120d284AafbA8fc4735;
    address private constant WETH9 = 0xc778417E063141139Fce010982780140Aa0cD5Ab;

    constructor(uint256 initialPrice) {
        price = initialPrice;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function changeOwner(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }

    function setPrice(uint256 newPrice) public onlyOwner{
        price = newPrice;
    }

    function paySubscription() external payable{
        if (msg.value > 0) {
            swapEthToDai();//TODO
        }
        
        else{
            // This contract must be approved to use msg.sender DAI
            TransferHelper.safeTransferFrom(DAI, msg.sender, address(this), price);
        }

        subscriptions[msg.sender]=true;

    }

    function swapEthToDai() internal{
        require(msg.value > 0, "Must pass non 0 ETH amount");

        ISwapRouter.ExactOutputSingleParams memory params =
            ISwapRouter.ExactOutputSingleParams({
                tokenIn: WETH9,
                tokenOut: DAI,
                fee: 3000,
                recipient: msg.sender,
                deadline: block.timestamp + 15,
                amountOut: price,
                amountInMaximum: msg.value,
                sqrtPriceLimitX96: 0
            });

        swapRouter.exactOutputSingle{value: msg.value}(params);
        swapRouter.refundETH();

        // Refund leftover ETH to msg.sender
        (bool success,) = msg.sender.call{ value: address(this).balance }("");
        require(success, "refund failed");
    }

    receive() payable external {}
}