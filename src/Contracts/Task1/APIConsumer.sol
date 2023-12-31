// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";

contract APIConsumer is ChainlinkClient, ConfirmedOwner {

    using Chainlink for Chainlink.Request;

    bytes32 private jobId;
    uint256 private fee;

    event RequestPriceOfPair(bytes32 indexed requestId, string targetCurrent, string baseCurrency, string price);
    event RequestTemperatureOfPlace(bytes32 indexed _requestId, string _time, string _latitude, string _longitude, string _temperature);
    event RequestScoreOfaMatch(bytes32 indexed _requestId, string _team1_id, string _team2_id, string _score);
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
     * I recommend having different contracts for different types of data.
     * I will provide a multi-API contract and different contracts, which
     * I recommend. 
     */

    /**
     * We repeat the process for temperature of a place. Although, we can get a full
     * JSON object to parse and use, I decide to only get the temperature to match
     * the price data as before. 
     * Create a Chainlink request to retrieve API response, find the target
     * data.
     * Notice that we take the pair from the user using the UI page.
     * I will use meteomatics.com as my API provider for weather data. 
     */
    function requestTemperatureData(
        string memory _time, 
        string memory _latitude, 
        string memory _longitude
        ) public returns (bytes32 requestId) {
        string memory url = string.concat("api.meteomatics.com/", _time ,"/t2_m:C/",
         _latitude ,",", _longitude ,"/format?json"); 
        //t2_m:C is the parameter used for temperature in centigrade.

        Chainlink.Request memory req = buildChainlinkRequest(
            jobId,
            address(this),
            this.fulfillTemperature.selector
        );

        // Set the URL to perform the GET request on
        req.add("get", url);

        // Set the path to find the desired data in the API response, where the response format is:
        // {"data":[
        //   {"coordinates": [
        //    {"date": [
        //     {
        //      "value": xxx.xxx,
        //     }
        //    }]
        //   }]
        //  }]
        // request.add("path", "data[0],coordinates[0],date[0],value"); // Chainlink nodes prior to 1.0.0 support this format
        req.add("path", "data[0],coordinates[0],date[0],value"); // Chainlink nodes 1.0.0 and later support this format

        // Sends the request
        return sendChainlinkRequest(req, fee);

        
    }

    /**
     * Receive the response in the form of uint256
     */
    function fulfillTemperature(
        bytes32 _requestId,
        string memory _time, 
        string memory _latitude, 
        string memory _longitude, 
        string memory _temperature
        ) public recordChainlinkFulfillment(_requestId) returns (string memory) {
        emit RequestTemperatureOfPlace(_requestId, _time, _latitude, _longitude, _temperature);
        return _temperature;
    }

    /**
     * We repeat the process for traffic in a route between two places. Although, we can get a full
     * JSON object to parse and use, I decide to only get the travelTime to match
     * the price data as before. 
     * Create a Chainlink request to retrieve API response, find the target
     * data.
     * Notice that we take the pair from the user using the UI page.
     * I will use myptv.com as my API provider for traffic data. 
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
     * We repeat the process for scores of a match. Although, we can get a full
     * JSON object to parse and use, I decide to only get the score of a specific 
     * soccer game, if it is live and being played, to  match the price data as before. 
     * Create a Chainlink request to retrieve API response, find the target
     * data.
     * Notice that we take the pair from the user using the UI page.
     * I will use live-score-api.com as my API provider for score data. 
     * Since this API provider only provides paid data we need to fill {demo_key}
     * and {demo_secret} in a secret way, like by giving it using the inputs.
     */
    function requestScoreData(
        string memory _team1_id, 
        string memory _team2_id
        ) public returns (bytes32 requestId) {
        string memory url = string.concat("https://livescore-api.com/api-client/scores/live.json?&key={demo_key}&secret={demo_secret}&team1_id=",
         _team1_id ,"&team2_id=", _team2_id);

        Chainlink.Request memory req = buildChainlinkRequest(
            jobId,
            address(this),
            this.fulfillScore.selector
        );

        // Set the URL to perform the GET request on
        req.add("get", url);

        // Set the path to find the desired data in the API response, where the response format is:
        // {"data":
        //   {"match": [
        //    {
        //        "score": 
        //    }
        //   }]
        //  }
        // request.add("path", "data,match[0],score"); // Chainlink nodes prior to 1.0.0 support this format
        req.add("path", "data,match[0],score"); // Chainlink nodes 1.0.0 and later support this format

        // Sends the request
        return sendChainlinkRequest(req, fee);

        
    }

    /**
     * Receive the response in the form of uint256
     */
    function fulfillScore(
        bytes32 _requestId,
        string memory _team1_id, 
        string memory _team2_id,  
        string memory _score
        ) public recordChainlinkFulfillment(_requestId) returns (string memory) {
        emit RequestScoreOfaMatch(_requestId, _team1_id, _team2_id, _score);
        return _score;
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

