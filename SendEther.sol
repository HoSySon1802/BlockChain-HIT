pragma solidity >=0.4.17;

contract Ether {
    


    address payable[] public  person;

    address public owner;


    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {

        if(msg.sender != owner){
            revert();
        }
        _;
    }

    function register(address payable _addressPerson) public onlyOwner {

        person.push(_addressPerson);

    }

    function invest() external payable onlyOwner {

    }

    function getBalance() public view returns(uint) {

        return address(msg.sender).balance;

    }


    function sendEther() payable public onlyOwner {

        for(uint i = 0 ; i < person.length; i++){
            
            person[i].transfer(1 ether);
        }
    }

}
