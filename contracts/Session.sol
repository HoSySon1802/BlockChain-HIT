pragma solidity ^0.4.17;

// interface Main {
//     function addSession(address session) public;
// }
import "./Main.sol";

contract Session {

    enum State {START,REGISTER,VOTE,CLOSING,CLOSED}

    address public mainContract;


    Main MainContract;
    string productName;
    string productDescription;
    string imageProduct;
    uint proposedPrice; // ket qua cuoi
    address[] participantJoin;
    mapping (address => uint ) participantGivenPrice;
    State state;


    constructor (address _mainContract,string  _productName, string  _productDescription, string _imageProduct) public {

        mainContract = _mainContract;
        MainContract = Main(_mainContract);
        MainContract.addSession(address(this));
        productName = _productName;
        productDescription = _productDescription;
        imageProduct = _imageProduct;
        state = State.START;
    }

    function addParticipant(address _address) external {
        participantJoin.push(_address);
    }

    function changeStateToRegister() external {
        state = State.REGISTER;
    }

    function changeStateVote() external {
        state = State.VOTE;
    }

    function changeStateClosing() external {
        state = State.CLOSING;
    }




    function voting(address _personVote,uint _numberVote) public  {
        participantGivenPrice[_personVote] = _numberVote;
    }

    function personJoin(address _person ) external view returns (bool) {

        bool check = false;

        for(uint i = 0; i < participantJoin.length; i++) {

            if( participantJoin[i] == _person) {
                check = true;
                break;
            }
        }
        return check;
    }


    function Caculate() public {

        uint _sumOfProposed = 0;
        uint _sumOfDeviation = 0;
        address _person;

        // caculate Proposed.

        for(uint i = 0; i < participantJoin.length ; i++) {  
            _person =  participantJoin[i];
            _sumOfProposed += participantGivenPrice[_person]*(100*1000 - MainContract.getDeviation(_person));
            _sumOfDeviation += MainContract.getDeviation(_person);
        }

        _sumOfProposed = _sumOfProposed*1000;
        proposedPrice = _sumOfProposed/( 1000*100*participantJoin.length - _sumOfDeviation);

        // caculate
        for( i = 0; i < participantJoin.length ; i++) {
            _person =  participantJoin[i];
            uint _proposedNew = participantGivenPrice[_person]*1000;
            //uint _numberPerson
            uint _dnew;
            if(proposedPrice >= _proposedNew) {
                _dnew = (proposedPrice - _proposedNew) *100*1000;
            }
            else {
                _dnew = (_proposedNew - proposedPrice) *100*1000;
            }
            _dnew = _dnew/ proposedPrice ;

            uint numberSessionForPerson = MainContract.getNumberSession(_person);
            uint _d = ( MainContract.getDeviation(_person) * numberSessionForPerson + _dnew);
            numberSessionForPerson +=1;

            uint d = _d / numberSessionForPerson ;

            
            MainContract.updateLastSession(_person,numberSessionForPerson,d);
        }

        //change state
        state = State.CLOSED;
    }

    function getProposed() external view returns(uint) {
        return proposedPrice;
    }
    function getProductName() external view returns(string ) {
        return productName;
    }
    function getProductDescription() external view returns(string) {
        return productDescription;
    }
    function listParticipantJoin() external view returns(address[]) {
        return participantJoin;
    }
    function getState() external view returns(uint) {
        return uint(state);
    }
    function getImage() external view returns(string) {
        return imageProduct;
    }

    //function viewSessionn() public view returns(s)
}
