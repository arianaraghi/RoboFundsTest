// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";

contract MarketDataOracle is ChainlinkClient, ConfirmedOwner {

    using Chainlink for Chainlink.Request;

    bytes32 private jobId;
    uint256 private fee;

    event RequestPriceOfPair(bytes32 indexed requestId, string targetCurrent, string baseCurrency, string price);
    /**
     * Oracle: ChainLink
     * Network: Fantom (Testnet for now)
     * Aggregator: Will be taken from user in the UI page
     * Address: Will be taken from user 
     * Link Token (On Fantom testnet): 0xfaFedb041c0DD4fA2Dc0d87a6B0979Ee6FA7af5F (We take it manually from the deployer)
     * Oracle: 0xcc79157eb46f5624204f47ab42b3906caa40eab7 (Chainlink DevRel for Fantom Testnet) (We take it manually from the deployer)
     * jobId: ca98366cc7314957b8c012c72f05aeeb
     * fee: The amount we will be giving ChainLink in order to get the data we need
     */
    constructor(address _linkTokenAddress, address _linkOracleAddress) ConfirmedOwner(msg.sender) {
        setChainlinkToken(_linkTokenAddress);
        setChainlinkOracle(_linkOracleAddress);
        jobId = "ca98366cc7314957b8c012c72f05aeeb";
        fee = (1 * LINK_DIVISIBILITY) / 10; // 0,1 * 10**18 (Varies by network and job)
    } 
    

    /**
     * Create a Chainlink request to retrieve API response, find the target
     * price data.
     * Note that we can get a full JSON object and use many data such as price, volume, etc. 
     * We just get the price data for different pairs, to make it a bit more simple to read. 
     * Notice that we take the pair from the user using the UI page.
     * I will use cryptocompare.com as my API provider for market data. 
     */
    function requestPriceData(string memory _baseCurrency, string memory _targetCurrency) public returns (bytes32 requestId) {
        string memory url = string.concat("https://min-api.cryptocompare.com/data/pricemultifull?fsyms=", _targetCurrency, "&tsyms=", _baseCurrency);

        Chainlink.Request memory req = buildChainlinkRequest(
            jobId,
            address(this),
            this.fulfillPrice.selector
        );

        // Set the URL to perform the GET request on
        req.add("get", url);

        // Set the path to find the desired data in the API response, where the response format is:
        // {"RAW":
        //   {"_targetCurrency":
        //    {"_baseCurrency":
        //     {
        //      "PRICE": xxx.xxx,
        //     }
        //    }
        //   }
        //  }
        // request.add("path", "RAW.ETH.USD.PRICE"); // Chainlink nodes prior to 1.0.0 support this format
        req.add("path", string.concat("RAW,",_targetCurrency,",",_baseCurrency,",PRICE")); // Chainlink nodes 1.0.0 and later support this format

        // Multiply the result by 1000000000000000000 to remove decimals
        int256 timesAmount = 10 ** 18;
        req.addInt("times", timesAmount);

        // Sends the request
        return sendChainlinkRequest(req, fee);
    }

    /**
     * Receive the response in the form of uint256
     */
    function fulfillPrice(
        bytes32 _requestId,
        string memory _targetCurrent, 
        string memory _baseCurrency,
        string memory _price
        ) public recordChainlinkFulfillment(_requestId) returns (string memory) {
        emit RequestPriceOfPair(_requestId, _targetCurrent, _baseCurrency, _price);
        return _price;
    }




    /**
     * Allow withdraw of Link tokens from the contract
     */
    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        require(
            link.transfer(msg.sender, link.balanceOf(address(this))),
            "Unable to transfer"
        );
    }
}

