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

        else if (block.timestamp-startTime < 60){

            status=StateTransition.Gift; // 60-90 seconds after deploy is time of recieve gift.
        }
        _;

    }

    function register() public payable updateStatus {

        require(status==StateTransition.Register , "not register time !");

        require(members[msg.sender].ismember==false , "you have registered already !");

        require(members[msg.sender].ispaid==false , "you have paid already !");

        require(msg.value==1e18,"you must pay 1 ether to register !");

        members[msg.sender].ismember= true;

        members[msg.sender].ispaid= true;

        member_Count[memberCount]=msg.sender;

        memberCount++;


    }

    function awaik() public updateStatus {

        require(status==StateTransition.Awaik_Cancel , "not Awaik/Cancel  time !");

        require(members[msg.sender].isAwaik==false, "you have Awaiked already !");

        require(members[msg.sender].ismember==true , "you have not registered yet !");

        require(members[msg.sender].ispaid==true, "you have not paid yet !");

        require(members[msg.sender].isCancel==false, "you have canceled already !");

        require(members[msg.sender].recieveGift==false, "you have recieved gift already !");

        members[msg.sender].isAwaik= true;

        awaikMember++;

    }

    function cansel() public updateStatus {

        require(status==StateTransition.Awaik_Cancel , "not Awaik/Cancel  time !");

        require(members[msg.sender].ismember==true , "you have not registered yet !");

        require(members[msg.sender].ispaid==true, "you have not paid yet !");

        require(members[msg.sender].isCancel==false, "you have canceled already !");

        require(members[msg.sender].recieveGift==false, "you have recieved gift already !");

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

    function gift() public updateStatus {

        require(status==StateTransition.Gift , "not Get price  time !");

        require(members[msg.sender].ismember==true , "you have not registered yet !");

        require(members[msg.sender].ispaid==true, "you have not paid yet !");

        require(members[msg.sender].isAwaik==true, "you have not awaik yet !");

        require(members[msg.sender].isCancel==false, "you have canceled already !");

        require(members[msg.sender].recieveGift==false, "you have recieved gift already !");


        if(determineGift==false){

                determineGift_= (address(this).balance-(awaikMember*(10**18)))/awaikMember;
                determineGift=true;
        }

        bool resualt= payable(msg.sender).send(determineGift_);
        assert(resualt==true);
        members[msg.sender].recieveGift=true;


    }



}