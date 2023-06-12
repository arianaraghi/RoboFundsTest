# RoboFundsTest
This repository is built for test tasks of RoboFunds sturtup. The task codes can be found in src folder based on the number of task. 

Task 1: 

In this task I provided a full Oracle for market data, weather, and live soccer scores. Also, as I mentioned in this specific contract, I recommend having different contracts for different types of API calls. This is because not only the contract deployment fee is reduced for each of them, it reduces the complexity of working with the contract. Also, if we need to deploy the contract at different steps of the project, having different contracts help us fulfill this without extra labor. 
Therefore, I decided to provide different contracts for the different data. The market data contract also helps me to fulfill the second task. 



Task 2: 

In the second task, I used the market data contract we wrote before as our Oracle. Here, I provided a very simple, static analysis especially for BTC/USD price. This analysis is not a good one and I never recommend using it, but I just wrote it as an example. Also, I noted in the comments that I don't recommend doing the analysis in the smart contract. One main reason is the "immutable" feature of the contract. 

If we need to update the analysis, we need to either upgrade the smart contract into a new one, which reduces the security and trust to our contract, or we need to deploy a fully new contract that costs us the deployment fee. Also, based on the market situation our analysis can vary and makes us deploy many contracts that will costs us a fortune. Another reason is that If we deploy complex analysis into the contract, other than the fact that we will sacrifise our "confidential" information about how we analyze the market, the contract caller has to pay a lot of gas to cover the the complex analysis, which will not be suitable for any customer. Therefore, I recommend doing the analysis off-chain and give the result of that analysis to the smart contract to do the job on-chain. This can be done either by giving the results as the nputs , or by APIs and Oracles like ChainLink or Band Protocol. 




Task 3:

Since smart contracts are as fast as the underneath blockchain layer, and the Oracle they are waiting for answer from, I don't see any on-chain recommendation to make them faster than they already are. Of course, we can make them more gas efficient using various techniques; hence, making them a bit faster. But, still they cannot be faster than the oracle they are calling and the blockchain underneath.

We can do some other things to make them run faster, off-chain. 
1. If the underlying blockchain supports sharding, we can deploy the contract on different shards to make the Oracle calls work faster. Of course, handling which customer goes to which shard needs a load balancer that it is better to be off-chain. If the load balancer is an on-chain smart contract it has the exact same limitations of the first smart contract we deployed. It can not be faster than the shard below it; hence, no point in making the load balancer at all. Note that this approach sacrifises the trustlessness, hence, the security.
2. We can run our API calls off-chain. Since Oracles wait a number of blocks to make sure the data the node provids is accurate, we will have a problem of contract waits, no matter what. But, in off-chain API calls, there is no wait; therfore, there is no delay in deploying the smart contract. Of course, it is obvious that making this move, again, sacrifises the trustlessness. 
3. We can store some previous data in the event calls that we made before, and use them in our on-chain analysis. This probably won't make the contract faster at all. Because, we need an API call to those transactions. No need to say that this is exactly the previous case.
4. We can cache some data off-chain. This, again, can be given to the cantract in two ways. Either we use API calls, which is the previous case, or we need to give the data as inputs. In the later, we, again, sacrifise the trustlessness, since we are using off-chain data that cannot be validated on-chain.

Anyway, I don't see any on-chain action to make a transaction faster than the underlying blockchain and the Oracle it is using, other than off-chain actions. 

I mentioned there are some ways to make the contract more gas-efficient, therfore a little faster. Here are some of them:

1. Optimizing the order of variable declaration: this can help memory management and can use less gas and making the contract faster. 
2. Using Mappings instead of Arrays: by design, Mappings are cheaper and faster than Arrays. If possible, we have to use Mappings instead of Arrays.
3. Avoid changing storage data: changing storage data is very costly. We have to avoid changing them, as much as possible.
4. Minimizing use of loops: this one is as obvious as "the sky is blue in day light."
