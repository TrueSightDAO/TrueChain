pragma solidity ^0.8.15;

contract Hello {
   string public message;

   function ping() public {
      message = "Hello, World : This is a Solidity Smart Contract on the Private Ethereum Blockchain ";
   }
}