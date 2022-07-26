pragma solidity ^0.8.15;

contract HelloMessage {

   address private _owner;
   address private _factory;
   string public _message;

   modifier onlyOwner(address caller) {
      require(caller == _owner, "You're not the owner of the contract");
      _;
    }

    modifier onlyFactory() {
      require(msg.sender == _factory, "You need to use the factory");
      _;
    }

   constructor(address owner) {
      _owner = owner;
      _factory = msg.sender;
    }

   function getMessage() public view returns (string memory) {
      return _message;
    }

    function setMessage(address caller, string memory new_message) public onlyFactory onlyOwner(caller) {
        _message = new_message;
    }

}

contract SenderHello {

    mapping(address => HelloMessage) _messages;

    function createMessage() public {
        require ( _messages[msg.sender] == HelloMessage(address(0)), "Message is already created" );
        _messages[msg.sender] = new HelloMessage(msg.sender);
    }

    function setMessage(string memory new_message) public {
        require (_messages[msg.sender] != HelloMessage(address(0)), "Message not created yet" );
        HelloMessage(_messages[msg.sender]).setMessage(msg.sender, new_message);
    }

    function getMessage(address account) public view returns (string memory) {
        require (_messages[account] != HelloMessage(address(0)), "Message not created yet" );
        return (_messages[account].getMessage());
    }

    function getMyMessage() public view returns (string memory) {
         require (_messages[msg.sender] != HelloMessage(address(0)), "Message not created yet" );
        return (getMessage(msg.sender));
    }

}