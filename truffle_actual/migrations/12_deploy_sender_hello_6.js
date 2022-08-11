var SenderHello6 = artifacts.require("./SenderHello6.sol");
var HelloMessage6 = artifacts.require("./SenderHello6.sol");

// const Web3 = require('web3');
// const TruffleConfig = require('../truffle');
console.log("Deploying Hello 6")
module.exports = function(deployer) {

   // const config = TruffleConfig.networks["development"];
   // if (process.env.ACCOUNT_PASSWORD) {
   //    const web3 = new Web3(new Web3.providers.HttpProvider('http://' + config.host + ':' + config.port));

   //    console.log('>> Unlocking account ' + config.from);
   //    web3.personal.unlockAccount(config.from, process.env.ACCOUNT_PASSWORD, 36000);
   // }
   
   deployer.deploy(HelloMessage6);
   deployer.deploy(SenderHello6);
};