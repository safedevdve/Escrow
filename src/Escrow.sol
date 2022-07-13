// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;


/**
 * @dev This contract allows for a 'buyer' to lock funds with a 'seller' to recieve these funds after 
 * the buyer determines conditions are met. At any time the seller may call off the deal and return 
 * funds to the buyer. After a predetermined deadline is passed, the buyer may back out of the deal and
 * reclaim their funds.
 */
contract Escrow {

  mapping(address => Agreement) public agreements;

  struct Agreement {
    address payable seller;
    uint256 amount;
    uint256 deadline;
    bool active;
  }

  /**
   * @dev Creates an Agreement struct indexed by msg.sender as the buyer. The buyer must send funds,
   * record the recipient of these funds (the seller), and set a deadline for the seller to complete
   * the terms of the agreement offchain.
   *
   * deadline should be a unix timestamp
   */
  function startEscrow(
    address payable seller,
    uint256 deadline) 
  public payable {
    require(msg.sender != seller, "Escrow: Addresses must be distinct");
    require(msg.value > 0, "Escrow: Payment not sent");
    require(agreements[msg.sender].active == false, "Escrow: Already active for this address");
    
    agreements[msg.sender].seller = seller;
    agreements[msg.sender].amount = msg.value;
    agreements[msg.sender].deadline = deadline;
    agreements[msg.sender].active = true;
  }

  /**
   * @dev When called by the buyer, this function sends the seller all funds and closes the agreement.
   *
   */
  function releaseFunds() public {
    require(agreements[msg.sender].active, "Escrow: No active agreement for this address");

    agreements[msg.sender].seller.transfer(agreements[msg.sender].amount);
    agreements[msg.sender].active = false;
  }

  /**
   * @dev When called by the seller, this function returns funds to the buyer and closes the agreement.
   *
   */
  function voidAgreement(address payable buyer) public {
    require(agreements[buyer].active, "Escrow: No active agreement for this address");
    require(msg.sender == agreements[buyer].seller, "Escrow: Only the buyer can void this agreement");

    buyer.transfer(agreements[buyer].amount);
    agreements[buyer].active = false;
  }

  /**
   * @dev When called by the buyer after the deadline, this function sends the seller all funds and 
   * closes the agreement.
   *
   */
  function recallFunds() public {
    require(agreements[msg.sender].active, "Escrow: No active agreement for this address");
    require(block.timestamp >= agreements[msg.sender].deadline, "Escrow: Deadline not yet hit");

    payable(msg.sender).transfer(agreements[msg.sender].amount);
    agreements[msg.sender].active = false;
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

  function getDeadline(address buyer) public view returns(uint256) {
    return agreements[buyer].deadline;
  }
 
} 
