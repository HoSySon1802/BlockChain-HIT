pragma solidity ^0.4.17;

import "./Session.sol";


contract Main {

    struct IParticipant {
        address accountsAddress;
        string email;
        string fullName;
        uint numberSession; // so phien dau gia da tham gia
        uint deviation; // chenh lech
    }

    address public admin; // admin adddress;
   // IParticipant[] public participants; /// mang luu nguoi thamm gia
    mapping( address => IParticipant) public mapParticipant;
    address[] public sessionArray;

    constructor () public {
        admin = msg.sender;
    }

    modifier onlyAdmin { // only Admin
        require(msg.sender == admin, "not is Admin");
        _;
    }

    modifier onlyState(uint _numberSession, uint _state) {   // onnlyState

        address _addressSession = sessionArray[_numberSession];
        Session _sessionPresent = Session(_addressSession);
        require(_sessionPresent.getState() == _state, "The state is not suitable for performing the operation" );
        _;
    }

    function getStateSession(uint _numberOfSession) public view returns(uint) { // lay state session
        Session _sessionPresent = Session(sessionArray[_numberOfSession]);
        return _sessionPresent.getState();
    }

    function register(string _fullName,string _email) public {

        require(mapParticipant[msg.sender].accountsAddress == address(0x0),"user is exits");
        
        IParticipant memory _person = IParticipant(msg.sender,_email,_fullName,0,0);
        mapParticipant[msg.sender] = _person;
    }

    function createSession(string memory _productName, string memory _productDescription, string memory _imageProduct) public onlyAdmin {
        new Session(address(this),_productName,_productDescription, _imageProduct);
    }

    function changeRegister(uint _numberOfSession) public onlyAdmin onlyState(_numberOfSession,0) {
        address _addressSession = sessionArray[_numberOfSession];
        Session _sessionPresent = Session(_addressSession);
        _sessionPresent.changeStateToRegister();
    }

    function regisSession(uint _numberSession ) public onlyState(_numberSession,1) {

        require(_numberSession < sessionArray.length,"number Session not exit"); // session da duoc dang ki chua
        require( mapParticipant[msg.sender].accountsAddress != address(0x0),"person is not registered");// account phai duoc dang ki ung dung roi


        address _addressSession = sessionArray[_numberSession];
        Session _sessionPresent = Session(_addressSession);

        require(_sessionPresent.personJoin(msg.sender) == false , "registered users to this version"); // account chưa từng đăng kí session
        
        _sessionPresent.addParticipant(msg.sender);

    }

    function changeVote(uint _numberOfSession) public onlyAdmin onlyState(_numberOfSession,1) {
        address _addressSession = sessionArray[_numberOfSession];
        Session _sessionPresent = Session(_addressSession);
        _sessionPresent.changeStateVote();
    }


    function vote(uint _sessionVote,uint _numberVote) public onlyState(_sessionVote,2) {
        address _addressSession = sessionArray[_sessionVote];
        Session _sessionPresent = Session(_addressSession);
        require(_sessionPresent.personJoin(msg.sender),"person is not registered" );
        _sessionPresent.voting(msg.sender,_numberVote);
    }

    function changeClosing(uint _numberOfSession) public  onlyAdmin onlyState(_numberOfSession,2) {
        address _addressSession = sessionArray[_numberOfSession];
        Session _sessionPresent = Session(_addressSession);
        _sessionPresent.changeStateClosing();
    }

    function endSession( uint _numberOfSession ) public onlyAdmin onlyState(_numberOfSession,3)  {
        address _addressSession = sessionArray[_numberOfSession];
        Session _sessionPresent = Session(_addressSession);
        _sessionPresent.Caculate();
    }


    function updateAdmin(
        address _accountAddress,
        string memory _email,
        string memory _fullName,
        uint _numberSession,
        uint _deviation
    ) public onlyAdmin {
        require(mapParticipant[_accountAddress].accountsAddress != address(0x0)," user not exits");
        IParticipant memory _person = IParticipant( _accountAddress, _email, _fullName, _numberSession, _deviation);
        mapParticipant[_accountAddress] = _person;
    } 


    function updateUser(string memory _fullName, string memory _email) public {
        require(mapParticipant[msg.sender].accountsAddress != address(0x0), "user not exits");
        mapParticipant[msg.sender].fullName = _fullName;
        mapParticipant[msg.sender].email = _email;
    }

    

    function addSession(address session ) external {
        sessionArray.push(session);
    }

    function getDeviation(address _person) external view returns(uint) {
        return mapParticipant[_person].deviation;
    }

    function setDeviation(address _person, uint _newDeviation ) external {
        mapParticipant[_person].deviation = _newDeviation; 
    }

    function getNumberSession(address _person) external view returns(uint) {
        return mapParticipant[_person].numberSession; 
    }

    function setNumberSession(address _person) external {
        mapParticipant[_person].numberSession +=1;
    }

    function getProposedOfSession(uint _numberOfSession) public view returns(uint) {
        address _addressSession = sessionArray[_numberOfSession];
        Session _sessionPresent = Session(_addressSession);
        return _sessionPresent.getProposed();
    }

    function updateLastSession(address _person, uint _numberSession, uint _deviation) external {
        mapParticipant[_person].numberSession = _numberSession;
        mapParticipant[_person].deviation = _deviation;
    }


}
