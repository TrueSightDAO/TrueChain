var SenderHello4 = artifacts.require("./SenderHello4.sol");
var HelloMessage4 = artifacts.require("./SenderHello4.sol");

// const Web4 = require('web4');
// const TruffleConfig = require('../truffle');

module.exports = function(deployer) {

   // const config = TruffleConfig.networks["development"];
   // if (process.env.ACCOUNT_PASSWORD) {
   //    const web4 = new Web4(new Web4.providers.HttpProvider('http://' + config.host + ':' + config.port));

   //    console.log('>> Unlocking account ' + config.from);
   //    web4.personal.unlockAccount(config.from, process.env.ACCOUNT_PASSWORD, 46000);
   // }

   deployer.deploy(HelloMessage4);
   deployer.deploy(SenderHello4);
};