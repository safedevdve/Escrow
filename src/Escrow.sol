// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Escrow {

  mapping(address => Agreement) public agreements;

  struct Agreement {
    address seller;
    uint256 amount;
    uint64 timeLimit;
    bool active;
  }

  function startEscrow(
    address seller,
    uint64 timeLimit) 
  public payable {
    require(msg.sender != seller, "Escrow: Addresses must be distinct");
    require(msg.value > 0, "Escrow: Payment not sent");
    require(agreements[msg.sender].active == false, "Escrow: Already active for this address");
    
    agreements[msg.sender].seller = seller;
    agreements[msg.sender].amount = msg.value;
    agreements[msg.sender].timeLimit = timeLimit;
    agreements[msg.sender].active = true;
  }

  /****************** VIEW ******************/

  function isActive(address buyer) public view returns(bool) {
    return agreements[buyer].active;
  }

  function getSeller(address buyer) public view returns(address) {
    return agreements[buyer].seller;
  }

  function getAmount(address buyer) public view returns(uint256) {
    return agreements[buyer].amount;
  }

  function getTimeLimit(address buyer) public view returns(uint64) {
    return agreements[buyer].timeLimit;
  }
 
} 
