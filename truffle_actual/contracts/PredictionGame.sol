pragma solidity ^0.8.15;

contract Prediction {

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

   function getPrediction() public view returns (string memory) {
      return _message;
    }

    function setPrediction(address caller, string memory new_message) public onlyFactory {
        _message = new_message;
    }

   function getPredictionOwner() public view returns (address owner) {
      return _owner;
    }    

}

contract PredictionGame {

    mapping(address => Prediction) _predictions;

    function createPrediction() public {
        require ( _predictions[msg.sender] == Prediction(address(0)), "Prediction is already created" );
        _predictions[msg.sender] = new Prediction(msg.sender);
    }

    function setPrediction(string memory new_message) public {
        require (_predictions[msg.sender] != Prediction(address(0)), "Prediction not created yet" );
        Prediction(_predictions[msg.sender]).setPrediction(msg.sender, new_message);
    }

    function getPrediction(address account) public view returns (string memory) {
        require (_predictions[account] != Prediction(address(0)), "Prediction not created yet" );
        return (_predictions[account].getPrediction());
    }

    function getMyPrediction() public view returns (string memory) {
         require (_predictions[msg.sender] != Prediction(address(0)), "Prediction not created yet" );
        return (getPrediction(msg.sender));
    }

    function getPredictionOwner(address account) public view returns (address owner) {
        require (_predictions[account] != Prediction(address(0)), "Prediction not created yet" );
        return (_predictions[account].getPredictionOwner());
    }

    function getMyPredictionOwner() public view returns (address owner) {
        require (_predictions[msg.sender] != Prediction(address(0)), "Prediction not created yet" );
        return (getPredictionOwner(msg.sender));
    }    

}