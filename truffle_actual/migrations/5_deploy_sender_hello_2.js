var SenderHello2 = artifacts.require("./SenderHello2.sol");
var HelloMessage2 = artifacts.require("./SenderHello2.sol");

// const Web3 = require('web3');
// const TruffleConfig = require('../truffle');

module.exports = function(deployer) {

   // const config = TruffleConfig.networks["development"];
   // if (process.env.ACCOUNT_PASSWORD) {
   //    const web3 = new Web3(new Web3.providers.HttpProvider('http://' + config.host + ':' + config.port));

   //    console.log('>> Unlocking account ' + config.from);
   //    web3.personal.unlockAccount(config.from, process.env.ACCOUNT_PASSWORD, 36000);
   // }

   deployer.deploy(HelloMessage2);
   deployer.deploy(SenderHello2);
};