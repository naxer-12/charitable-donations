//SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

contract CharitableDonation {

    // Struct to hold charitable donors

    struct Donor {
        string name;
        uint amount;
    }

    // Struct for each charity that can receive donations

    struct Charity {
        address payable charityAddr;
        string name;
        uint donationsAccumulated;
        uint targetAmount;
        // a mapping of an individual donor address to a Donor struct which tracks their donation
        mapping(address=>Donor) donors;
    }

    // The charity
    Charity public charity;

    address public administrator;

    // Constructor

    constructor(address payable charityAddress,  string memory charityName) {
        administrator = msg.sender;
        charity.charityAddr = charityAddress;        
        charity.name = charityName;        
    }

    // set the donation target amount
    function setTargetAmount(uint _targetAmount) public {
        require(msg.sender == administrator, "Only the administrator can set the donation target amount!");
        charity.targetAmount = _targetAmount;
    }


    //Event to index the donar and its amount
    event DonationEvent(address indexed donorAddress, uint indexed amount);

    function addDonation(string memory _name) external payable{
        address donorAddress = msg.sender;
        uint amount = msg.value;

        
        
             
        charity.donors[donorAddress]=Donor({name: _name, amount: amount});
        emit DonationEvent(donorAddress, amount);
        
        //update charity donation accumulator
        charity.donationsAccumulated += amount;
        
    }
    


    modifier onlyAdministrator(){
        require(msg.sender==administrator,"Only administrator can perform this Action");
        _;
    }

    event FundReleaseEvent(uint indexed amount);

    function checkAndReleaseFunds() external onlyAdministrator returns(string memory output){
        require(address(this).balance >= charity.targetAmount,"Charity didn't reach target amount. Release is declined");
        (bool sent, ) = charity.charityAddr.call{value: address(this).balance}("");
        require(sent, "Transaction Error");
        charity.donationsAccumulated = 0;
        emit FundReleaseEvent(address(this).balance);
        return "Fund Released";  
    }
    
}