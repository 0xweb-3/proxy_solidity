// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract SelfDestruct {
    address payable public owner;
    bool public isActive = true;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier onlyWhenActive() {
        require(isActive, "Contract is not active");
        _;
    }

    constructor() {
        owner = payable(msg.sender);
    }

    function setIsActive () public returns (bool) {
        isActive = true;
        return isActive;
    }

    receive() external payable{}

    function deactivate() public onlyOwner {
        isActive = false;
    }

    function withdraw() public onlyOwner {
        owner.transfer(address(this).balance);
    }

    // Some function that should only be callable when active
    function doSomething() view public onlyWhenActive returns(uint256) {
        // function logic
        return 100;
    }
}
