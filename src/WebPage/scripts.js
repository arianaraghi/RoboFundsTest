function openTab(evt, tabName) {
    var i, tabContent, tabButtons;
    tabContent = document.getElementsByClassName("tab-content");
    for (i = 0; i < tabContent.length; i++) {
        tabContent[i].style.display = "none";
    }
    tabButtons = document.getElementsByClassName("tab-button");
    for (i = 0; i < tabButtons.length; i++) {
        tabButtons[i].className = tabButtons[i].className.replace(" active", "");
    }
    document.getElementById(tabName).style.display = "block";
    evt.currentTarget.className += " active";
}

document.addEventListener("DOMContentLoaded", function () {
    document.querySelector(".tab-button.active").click();
});

// Import the Web3.js library
const Web3 = require('web3');

// Check if MetaMask is installed
if (typeof window.ethereum !== 'undefined') {
    // Create a Web3 instance
    const web3 = new Web3(window.ethereum);

    // Request access to the user's MetaMask accounts
    window.ethereum
        .enable()
        .then(accounts => {
            // Get the current network ID
            web3.eth.net.getId()
                .then(networkId => {
                    // Check the current network
                    if (networkId !== 1) { // 1 represents Ethereum's mainnet, we can change it to Fantoms ID
                        console.log('Please switch to the Ethereum mainnet');
                    } else {
                        console.log('Connected to the Ethereum mainnet');
                    }
                })
                .catch(error => {
                    console.error('Error while getting network ID:', error);
                });

            // Send a message to MetaMask to sign
            const message = ""; //custom message to inform user about terms and policies, and what we will do through transactions
            web3.eth.personal.sign(message, accounts[0])
                .then(signature => {
                    console.log('Signature:', signature);
                })
                .catch(error => {
                    console.error('Error while signing message:', error);
                });

            // Call a contract function that requires user interaction

            //Market Data Oracle
            const marketDataOracleAddress = ""; // Replace with the Market Data Oracle ABI after deploying
            const marketDataOracleAbi = [
                //TO-DO
            ]; // Replace with the Market Data Oracle ABI after deploying

            const marketDataContract = new Web3.eth.Contract(marketDataOracleAbi, marketDataOracleAddress);



            // The same process happens for the other Oracles noticing the API IDs for cities and teams. 


            // Analyzing the pair price provided by the user. For each contract of pairs, we have to redefine below
            const marketDataAnalyzerAddress = ""; // Replace with the Market Data Oracle ABI after deploying
            const marketDataAnalyzerAbi = [
                //TO-DO
            ]; // Replace with the Market Data Oracle ABI after deploying

            const marketDataAnalyzerContract = new Web3.eth.Contract(marketDataOracleAbi, marketDataOracleAddress);

        })
        .catch(error => {
            console.error('Error while enabling MetaMask accounts:', error);
        });
} else {
    console.error('MetaMask is not installed');
}

async function marketDataOraclePrice() {
    const e1 = document.getElementById("first-currency");
    var text1 = e1.options[e1.selectedIndex].text;
    const e2 = document.getElementById("second-currency");
    var text2 = e2.options[e2.selectedIndex].text;
    const accounts = await web3.eth.getAccounts();
    const price = await marketDataContract.methods.requestPriceData(text2, text1).send({ from: accounts[0] });
    document.getElementById("market-price").textContent = price;
}

async function marketDataAnalyze() {
    const accounts = await web3.eth.getAccounts();
    const result = await marketDataAnalyzeContract.methods.analyzer().send({ from: accounts[0] });
    document.getElementById("analyze-result").textContent = result;
}

var popup;
function openPopup() {
    popup = window.open('popup.html', 'My Popup', 'width=400,height=150');
}

async function swap() {
    document.getElementById("waiting").textContent = "Please wait!";
    const amount = parseFloat(document.getElementById("amount").value) * (10 ^ 18);
    const accounts = await web3.eth.getAccounts();
    const result = await marketDataAnalyzeContract.methods.swapTokens(amount).send({ from: accounts[0] });
    window.close(popup);
    document.getElementById("analyze-result").textContent = "Your swap has been done for: " + toString(amount / (10 ^ 18)) + "WETH";
}