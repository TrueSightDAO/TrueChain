pragma solidity ^0.8.15;

contract Hello3 {
   string public objectStatus;

   function state1() public {
      objectStatus = "Hello, World : This is a Solidity Smart Contract on the Private Ethereum Blockchain ";
   }

   function state2() public {
      objectStatus = "I don't know what I am doing";
   }
}