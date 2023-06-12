// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";

contract MarketDataOracle is ChainlinkClient, ConfirmedOwner {

    using Chainlink for Chainlink.Request;

    bytes32 private jobId;
    uint256 private fee;

    event RequestTravelTime(bytes32 indexed _requestId, string _first_city_lat, string _first_city_long, 
    string _second_city_lat, string _second_city_long, string _travelTime);
    
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
     * traffic data.
     * Note that we can get a full JSON object and use many data such as price, volume, etc. 
     * We just get the price data for different pairs, to make it a bit more simple to read. 
     * Notice that we take the pair from the user using the UI page.
     * I will use cryptocompare.com as my API provider for market data. 
     */
    function requestTrafficData(
        string memory _first_city_lat, 
        string memory _first_city_long, 
        string memory _second_city_lat,
        string memory _second_city_long
        ) public returns (bytes32 requestId) {
        string memory url = string.concat("https://api.myptv.com/routing/v1/routes?waypoints=",
        _first_city_lat,",",_first_city_long,"&waypoints=",_second_city_lat, ",", _second_city_long,"&apiKey=YOUR_API_KEY"); 
        //t2_m:C is the parameter used for temperature in centigrade.

        Chainlink.Request memory req = buildChainlinkRequest(
            jobId,
            address(this),
            this.fulfillTraffic.selector
        );

        // Set the URL to perform the GET request on
        req.add("get", url);

        // Set the path to find the desired data in the API response, where the response format is:
        // {
        //    "travelTime"
        //  }
        // request.add("path", "travelTime"); // Chainlink nodes prior to 1.0.0 support this format
        req.add("path", "travelTime"); // Chainlink nodes 1.0.0 and later support this format

        // Sends the request
        return sendChainlinkRequest(req, fee);

        
    }

    /**
     * Receive the response in the form of uint256
     */
    function fulfillTraffic(
        bytes32 _requestId,
        string memory _first_city_lat, 
        string memory _first_city_long, 
        string memory _second_city_lat,
        string memory _second_city_long,
        string memory _travelTime
        ) public recordChainlinkFulfillment(_requestId) returns (string memory) {
        emit RequestTravelTime(_requestId, _first_city_lat, _first_city_long, _second_city_lat, _second_city_long, _travelTime);
        return _travelTime;
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

