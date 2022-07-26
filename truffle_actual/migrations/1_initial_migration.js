const Migrations = artifacts.require("Migrations");

// const Web3 = require('web3');
// const TruffleConfig = require('../truffle-config');

module.exports = function (deployer) {

   // const config = TruffleConfig.networks["development"];
   // if (process.env.ACCOUNT_PASSWORD) {
   //    const web3 = new Web3(new Web3.providers.HttpProvider('http://' + config.host + ':' + config.port));

   //    console.log('>> Unlocking account ' + config.from);
   //    web3.personal.unlockAccount(config.from, process.env.ACCOUNT_PASSWORD, 36000);
   // }

  deployer.deploy(Migrations);
};
