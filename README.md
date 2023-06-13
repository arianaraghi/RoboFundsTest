
# RoboFundsTest

**Note: Please consider that the project doesn't work. Since the API providers need active accounts to provide the API we need, and the JavaScript code needs deployed contract and is not completed yet.**

This repository is built for test tasks of RoboFunds startup. The task codes can be found in `src` folder based on the number of the task.

**Task 1:** Create a decentralized oracle that provides data to smart contracts on Fantom blockchain. 

In this task I provided a full Oracle for market data, weather, traffic data, and live soccer scores. Also, as I mentioned in this specific contract, I recommend having different contracts for different types of API calls. This is because not only the contract deployment fee is reduced for each of them, it reduces the complexity of working with the contract. Also, if we need to deploy the contracts in different steps of the project, having different contracts help us fulfill this without extra labor. Therefore, I decided to provide different contracts for the different data. The market data contract also helps me to fulfill the second task.

I should mention that I used ChainLink's [Single Word Responce for HTTP GET request]:(https://docs.chain.link/any-api/get-request/examples/single-word-response/). Because ChainLink doesn't support any data other than cryptocurrency market data (and some FX and commodity data), I needed to make direct API calls to some data providers in other fields like the weather data. This is why I used ChainLink as somewhat a middleman for my requests. Also, if we have many data requests like many DeFi platforms such as Aave and Curve, we can design our own Oracle using ChainLink's open source codes to get rid of the LINK fee that we have to give the ChainLink's nodes. 


**Task 2:** Create a smart contract that can analyze real-time market data on Fantom blockchain.

In the second task, I used the market data contract we wrote before as our Oracle. Here, I provided a very simple, static analysis specialized for BTC/USD price. This analysis is not a good one, and I never recommend using it, but I just wrote it as an example. Also, I noted in the comments that **I don't recommend doing the analysis in the smart contract**. 

One main reason is the "immutable" feature of the contract. If we need to update the analysis, we need to either upgrade the smart contract into a new one, which reduces the security and trust in our contract, or we need to deploy a fully new contract that costs us the deployment fee. Also, based on the market situation, our analysis can vary and makes us deploy many contracts that will cost us a fortune. 

Another reason is that If we deploy complex analysis into the contract, other than the fact that we will sacrifice our "confidential" information about how we analyze the market, the contract caller has to pay a lot of gas to cover the complex analysis, which will not be suitable for our customers.

Therefore, I recommend doing the analysis off-chain and give the result of that analysis to the smart contract to do the job on-chain. This can be done either by giving the results as the inputs, or by APIs and Oracles like ChainLink or Band Protocol. I recommend the first approach since it has much less cost for us and the contract user. 

**Task 3:** Create a smart contract that can handle a large number of transactions without compromising security or pace on Fantom blockchain.

Since smart contracts are as fast as the underneath blockchain layer and the Oracle they are waiting for an answer from, I don't see any on-chain recommendation to make them faster than they already are. As an example we can mention Uniswap contracts that are as fast as the Ethereum blockchain, never faster and never slower. If the blockchain is crowded with many transactions, the wait time to be included in a block increases. If number of transactions on the blockchain is low enough, all transactions will be included in the next block, if the blockchain is censorship-resistant. 

Of course, we can make them more gas efficient using various techniques; hence, making them a bit faster. But, still, they cannot be faster than the oracle they are calling and the blockchain underneath.

We can do some other things to make them run faster, **off-chain**:

1. If the underlying blockchain supports sharding, we can deploy the contract on different shards to make the Oracle calls work faster. Since every contract call is independant to all other calls, this technique cannot imrpove the scalability of our smart contracts significantly, we can use it to get a little faster than before. 
Of course, handling the process of which customer goes to which shard needs a load balancer, which is better to be off-chain. If the load balancer is an on-chain smart contract, it has the exact same limitations of the first smart contract we deployed. It can not be faster than the shard below it; hence, no point in making the load balancer at all. Note that this approach **sacrifices the trustlessness**, hence, the security.

2. We can run our API calls off-chain. Since Oracles wait a number of blocks to make sure the data that the node provides is accurate, we will have a problem of contract waits, no matter what. But, in off-chain API calls, there is no wait; therefore, there is no delay in deploying the smart contract. Of course, it is obvious that making this move, again, **sacrifices the trustlessness**. 

3. We can store some previous data in the event calls that we made before, and use them in our on-chain analysis. This probably won't make the contract faster at all. Because, we need an API call to those transactions, since there is no on-chain action that can help us have previous transactions. **No need to say that this is exactly the previous case**.

4. We can cache some data off-chain. This, again, can be given to the contract in two ways. Either we use API calls, which is the previous case, or we need to give the data as inputs. In both cases, we, again, **sacrifice the trustlessness**, since we are using off-chain data that cannot be validated on-chain.

Anyway, I don't see any on-chain action to make a transaction faster than the underlying blockchain and the Oracle it is using. Only off-chain actions are available.

I mentioned there are some ways **to make the contract more gas-efficient**, therefore a little faster. Here are some of them:

1. Optimizing the order of variable declaration: this can help memory management and can use less gas and making the contract faster. 

2. Using Mappings instead of Arrays: by design, Mappings are cheaper and faster than Arrays. If possible, we have to use Mappings instead of Arrays.

3. Avoid changing storage data: changing storage data is very costly. We have to avoid changing them, as much as possible.

4. Minimizing use of loops: this one is as obvious as "the sky is blue in daylight."

In terms of making the contract more gas-efficient, I have already done my best in the second task. So, I don't have any new contracts to upload for the third task.
