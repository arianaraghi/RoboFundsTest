// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";

contract APIConsumer is ChainlinkClient, ConfirmedOwner {

    using Chainlink for Chainlink.Request;

    bytes32 private jobId;
    uint256 private fee;

    event RequestScoreOfaMatch(bytes32 indexed _requestId, string _team1_id, string _team2_id, uint256 _score);

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
        uint256 _score
        ) public recordChainlinkFulfillment(_requestId) returns (uint256) {
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

