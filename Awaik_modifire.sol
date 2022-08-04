// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


contract Awaik{

    struct Member{

        bool ismember;
        bool isAwaik;
        bool ispaid;
        bool isCancel;
        bool recieveGift;
    }

    mapping(address => Member) members;
    mapping(uint => address) member_Count;
    uint memberCount=1;
    uint awaikMember=0;
    uint cancelMember=0;
    bool determineGift;
    uint determineGift_;

    address owner ;

    enum StateTransition {     // by this enum we can manage the event.

        Register ,
        Awaik_Cancel , 
        Gift
    }

    StateTransition status ;
    uint startTime;
    
    constructor(){

        owner=msg.sender;
        startTime = block.timestamp;
    }

    modifier updateStatus() {

        if(block.timestamp-startTime < 30){

            status=StateTransition.Register;  // 30 seconds to register voters after deploy contract
        }

        else if (block.timestamp-startTime < 60){

            status=StateTransition.Awaik_Cancel; // 30-60 seconds after deploy is time of awaik/cancel.
        }

        else if (block.timestamp-startTime < 90){

            status=StateTransition.Gift; // 60-90 seconds after deploy is time of recieve gift.
        }
        _;

    }

    modifier ismember(){
        require(members[msg.sender].ismember==false , "you have registered already !");
        _;
    }

    modifier isnotmember(){
        require(members[msg.sender].ismember==true , "you have not registered yet !");
        _;
    }

    modifier ispaid(){
        require(members[msg.sender].ispaid==false , "you have paid already !");
        _;

    }
    modifier isnotpaid(){
        require(members[msg.sender].ispaid==true , "you have not paid yet !");
        _;

    }

    modifier value_1ether(){
        require(msg.value==1e18,"you must pay 1 ether to register !");
        _;
    }

    modifier registerTime(){
        require(status==StateTransition.Register , "not register time !");
        _;
    }

    modifier awaik_cancel_time(){
        require(status==StateTransition.Awaik_Cancel , "not Awaik/Cancel  time !");
        _;
    }

        modifier gift_time(){
        require(status==StateTransition.Gift , "not Gift  time !");
        _;
    }

    modifier iscancel(){

        require(members[msg.sender].isCancel==false, "you have canceled already !");
        _;
    }

    modifier isawaik(){

        require(members[msg.sender].isAwaik==false, "you have Awaiked already !");
        _;
    }
    modifier isnotawaik(){

        require(members[msg.sender].isAwaik==true, "you have not Awaiked yet !");
        _;
    }

    modifier recieved_gift(){
        require(members[msg.sender].recieveGift==false, "you have recieved gift already !");
        _;
    }

    function register() public payable updateStatus registerTime ismember ispaid value_1ether {

        members[msg.sender].ismember= true;

        members[msg.sender].ispaid= true;

        member_Count[memberCount]=msg.sender;

        memberCount++;


    }

    function awaik() public updateStatus awaik_cancel_time isawaik isnotmember isnotpaid iscancel recieved_gift{

        members[msg.sender].isAwaik= true;

        awaikMember++;

    }

    function cansel() public updateStatus awaik_cancel_time isnotmember isnotpaid iscancel recieved_gift {


        if(members[msg.sender].isCancel==true){

            members[msg.sender].isAwaik= false;
            members[msg.sender].isCancel= true;
            awaikMember--;
        }

        members[msg.sender].isCancel= true;
        bool resualt= payable(msg.sender).send(1e18);
        assert(resualt==true);
        members[msg.sender].ismember==false;
        cancelMember++;

    }

    function getballance() public view returns(uint){

        return address(this).balance;
    }

    function gift() public updateStatus gift_time isnotmember isnotpaid isnotawaik iscancel recieved_gift {

        if(determineGift==false){

                determineGift_= (address(this).balance-(awaikMember*(10**18)))/awaikMember;
                determineGift=true;
        }

        bool resualt= payable(msg.sender).send(determineGift_);
        assert(resualt==true);
        members[msg.sender].recieveGift=true;


    }



}