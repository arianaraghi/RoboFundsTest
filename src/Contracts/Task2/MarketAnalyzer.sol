// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "https://github.com/arianaraghi/RoboFundsTest/blob/main/src/Contracts/Task1/MarketDataOracle.sol";
import "./SwapTokens.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

/**
 * It is said to create a smart contract for analyzing part. I will write the code in Solidity
 * language so it can be a smart contract easily. But, I recommend that analyzing and other 
 * time and fee consuming activities be executed off-chain and maybe on a server. Since, execution
 * fees can get very high, and because of the "immutable" nature of smart contracts, we are not
 * easily able to change the codes and analysis techniques through time.
 */

contract MarketAnalyzer {

    string private baseCurrency;
    string private targetCurrency; 
    address private targetCurrencyAddress;
    address private WETH;


    event Analyzed(string firstCurrency, uint256 price, string analysis);
    event Swapped(string firstCurrency, string secondCurrency, uint256 amountOfFirst, uint256 MinAmountOfSecond);


    constructor(string memory _baseCurrency, string memory _targetCurrency, address _targetCurrencyAddress){
        baseCurrency = _baseCurrency;
        targetCurrency = _targetCurrency;
        targetCurrencyAddress = _targetCurrencyAddress;
        WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    }

    /**
     * Fetching the current price of the pair we have set, using the Oracle we built before.
     */
    function _fetchPrice(string memory _baseCurrency,string memory _targetCurrency) private returns (uint256){
        return int(requestPriceData( baseCurrency, targetCurrency));
    }

    /**
     * Doing our analysis using our techniques. I don't have any specific analysis
     * at the moment; hence, I will write a very simple analaysis, for BTC/USD.
     * Using the events we can give back our analysis to the user. If the user wants
     * they can use our other functions to do our analysis. 
     */

    function analyzer() public view returns (string memory){
        uint256 price = _fetchPrice(baseCurrency, targetCurrency);
        if(price >= 22000){
            emit Analyzed(targetCurrency, price, "buy");
            return "buy";
        }
        else if (price <= 18000){
            emit Analyzed(targetCurrency, price, "sell");
            return "sell";
        }
        else {
            emit Analyzed(targetCurrency, price, "do nothing");
            return "do nothing";
        }
    }

    /**
     * This function buys the amount of the targetCurrnecy using the 
     * targetCurrenct/WETH pool in Uniswap on the Ethereum blockchain.
     * Everything can be easily changed to perform on other services on the 
     * Fantom blockchain. 
     * In this function I use another contract named SwapTokens that is
     * in the same directory as this contract. Notice that I didn't write that
     * contract and I just tried to use it here. 
     */
    function swapToken(uint256 _amount){
        uint256 targetCurrencyPrice = _fetchPrice(baseCurrency, targetCurrency);
        uint256 WETHPrice = _fetchPrice(_baseCurrency, "WETH");
        string memory result = analyzer();
        amountOutMin = div(mul(targetCurrencyPrice,1000000000000000000),WETHPrice);
        amountIn = mul(amount, 1000000000000000000);

        if (result == "buy"){
            swap(WETH, targetCurrencyAddress, amountIn, amountOutMin, msg.sender);
            emit Swapped("WETH", targetCurrency, amountIn, amountOutMin);
        }

        else if (result == "sell"){
            swap(targetCurrencyAddress, WETH, amountOutMin, amountIn, msg.sender);
            emit Swapped(targetCurrency, "WETH", amountOutMin, amountIn);
        }

    }


}
