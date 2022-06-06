// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract Ballot{
    //VARIABLES
    struct Voter{
        string candidiate;
        bool voted;
    }

    enum State{REGISTRATION, VOTING, CLOSED}
    State public currentState; 
    address public creator;
    string[] public candidateRegistry;
    mapping(address => Voter) public voterRegistry;
    mapping(string => uint) voteCount;
    uint public numCandidates = 0;

    //MODIFIERS
    modifier inState(State _state){
        require(currentState == _state);
        _;
    }

    modifier onlyCreator(){
        require(msg.sender == creator);
        _;
    }

    //FUNCTIONS
    constructor(){
        creator = msg.sender;
        currentState = State.REGISTRATION;
    }

    function closeRegistration() public inState(State.REGISTRATION) onlyCreator{
        currentState = State.VOTING;
    }

    function closeVoting() public inState(State.VOTING) onlyCreator{
        currentState = State.CLOSED;
    }

    function isValidCandidate(string memory candidate) public view returns(bool){
        for (uint i = 0; i < candidateRegistry.length; i++){
            if (keccak256(abi.encodePacked(candidateRegistry[i])) == keccak256(abi.encodePacked(candidate))){
                return false;
            }
        }
        return true;
    }
    
    function addCandidate(string memory _name) public inState(State.REGISTRATION){
        require(isValidCandidate(_name));
        candidateRegistry.push(_name);
        numCandidates++;
        voteCount[_name] = 0;
    }

    function doVote(string memory _name) public inState(State.VOTING){
        require(isValidCandidate(_name));
        require(!voterRegistry[msg.sender].voted);
        voterRegistry[msg.sender].voted = true;
        voteCount[_name] += 1;
    }

    function getWinner() public view inState(State.CLOSED) returns(string memory winner){
        uint highestCount = 0;
        uint id = 0;
        for (uint i = 0; i < candidateRegistry.length - 1; i++){
            if (voteCount[candidateRegistry[i]] > highestCount){
                highestCount = voteCount[candidateRegistry[i]];
                id = i;
            }
        }
        return candidateRegistry[id];
    }

}