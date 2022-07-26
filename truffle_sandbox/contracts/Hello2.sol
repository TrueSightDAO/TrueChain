pragma solidity ^0.8.15;

contract Hello2 {
   string public message;

   function ping() public {
      message = "Hello, World : This is a Solidity Smart Contract on the Private Ethereum Blockchain ";
   }

   function unPing() public {
      message = "I don't know what I am doing";
   }
}