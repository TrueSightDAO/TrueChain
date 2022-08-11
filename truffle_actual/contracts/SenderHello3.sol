pragma solidity ^0.8.15;

contract HelloMessage3 {

   address private _owner;
   address private _factory;
   string public _message;
   bool public _validated;

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
      _validated = false;
    }

    function getMessage() public view returns (string memory) {
      return _message;
    }

    function setMessage(address caller, string memory new_message) public onlyFactory {
        _message = new_message;
    }

    function getMessageOwner() public view returns (address owner) {
      return _owner;
    }

    function validate() public onlyFactory {
      _validated = true;
    }    

    function invalidate() public onlyFactory {
      _validated = false;
    }        

}

contract SenderHello3 {

    mapping(address => HelloMessage3) _messages;

    function createMessage() public {
        require ( _messages[msg.sender] == HelloMessage3(address(0)), "Message is already created" );
        _messages[msg.sender] = new HelloMessage3(msg.sender);
    }

    function setMessage(string memory new_message) public {
        require (_messages[msg.sender] != HelloMessage3(address(0)), "Message not created yet" );
        HelloMessage3(_messages[msg.sender]).setMessage(msg.sender, new_message);
    }

    function getMessage(address account) public view returns (string memory) {
        require (_messages[account] != HelloMessage3(address(0)), "Message not created yet" );
        return (_messages[account].getMessage());
    }

    function getMyMessage() public view returns (string memory) {
         require (_messages[msg.sender] != HelloMessage3(address(0)), "Message not created yet" );
        return (getMessage(msg.sender));
    }

    function getMessageOwner(address account) public view returns (address owner) {
        require (_messages[account] != HelloMessage3(address(0)), "Message not created yet" );
        return (_messages[account].getMessageOwner());
    }

    function getMyMessageOwner() public view returns (address owner) {
        require (_messages[msg.sender] != HelloMessage3(address(0)), "Message not created yet" );
        return (getMessageOwner(msg.sender));
    }    

    function validateMessage(address account) public {
        require (_messages[account] != HelloMessage3(account), "Message not created yet" );
        HelloMessage3(_messages[account]).validate();
    }

    function invalidateMessage(address account) public {
        require (_messages[account] != HelloMessage3(account), "Message not created yet" );
        HelloMessage3(_messages[account]).invalidate();
    }

}