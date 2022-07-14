// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/Escrow.sol";

contract ContractTest is Test {
  Escrow escrow;
  address payable addr0;

  receive() external payable {}

  function setUp() public {
    addr0 = payable(0x2DD0e7C4EfF32E33f5fcaeE2aadC99C691134bB5);
    escrow = new Escrow();
  }

  function testStartEscrowActive() public {
    escrow.startEscrow{ value: 1 ether }(addr0, block.timestamp);
    assertTrue(escrow.isActive(address(this)));
  }

  function testStartEscrowValuesAccurate() public {
    escrow.startEscrow{ value: 1 ether }(addr0, block.timestamp);
    
    assertEq(escrow.getSeller(address(this)), addr0);
    assertEq(escrow.getAmount(address(this)), 1 ether);
    assertEq(escrow.getDeadline(address(this)), block.timestamp);
  }

  function testFailStartEscrowNondistinctAddress() public {
    escrow.startEscrow{ value: 1 ether }(payable(this), block.timestamp);
  }

  function testFailStartEscrowNoPayment() public {
    escrow.startEscrow(addr0, 1 days);
  }

  function testFailStartEscrowRepeatAddress() public {
    escrow.startEscrow{ value: 1 ether }(addr0, block.timestamp);
    escrow.startEscrow{ value: 1 ether }(addr0, block.timestamp);
  }

  function testReleaseFundsDeactivates() public {
    escrow.startEscrow{ value: 1 ether }(addr0, block.timestamp);
    escrow.releaseFunds();

    assertFalse(escrow.isActive(address(this)));
  }

  function testReleaseFundsValueSent() public {
    uint256 escrowValue = 1 ether;
    escrow.startEscrow{ value: escrowValue }(addr0, block.timestamp);
    uint256 balanceBefore = address(escrow).balance;

    escrow.releaseFunds();
    uint256 balanceAfter = address(escrow).balance; 

    assertEq(balanceAfter, balanceBefore - escrowValue);
  }

  function testReleaseFundsValueRecieved() public {
    uint256 escrowValue = 1 ether;
    escrow.startEscrow{ value: escrowValue }(addr0, block.timestamp);
    uint256 balanceBefore = addr0.balance;

    escrow.releaseFunds();
    uint256 balanceAfter = addr0.balance; 

    assertEq(balanceAfter, balanceBefore + escrowValue);
  }

  function testFailReleaseFundsNotActive() public {
    escrow.releaseFunds();
  }

  function testVoidAgreementDeactivates() public {
    escrow.startEscrow{ value: 1 ether }(addr0, block.timestamp);

    vm.prank(addr0);
    escrow.voidAgreement(payable(this));

    assertFalse(escrow.isActive(address(this)));
  }

  function testVoidAgreementValueSent() public {
    uint256 escrowValue = 1 ether;
    escrow.startEscrow{ value: escrowValue }(addr0, block.timestamp);
    uint256 balanceBefore = address(escrow).balance;

    vm.prank(addr0);
    escrow.voidAgreement(payable(this));
    uint256 balanceAfter = address(escrow).balance; 

    assertEq(balanceAfter, balanceBefore - escrowValue);
  }

  function testVoidAgreementValueRecieved() public {
    uint256 escrowValue = 1 ether;
    escrow.startEscrow{ value: escrowValue }(addr0, block.timestamp);
    uint256 balanceBefore = address(this).balance;

    vm.prank(addr0);
    escrow.voidAgreement(payable(this));
    uint256 balanceAfter = address(this).balance; 

    assertEq(balanceAfter, balanceBefore + escrowValue);
  }

  function testFailVoidAgreementNotActive() public {
    vm.prank(addr0);
    escrow.voidAgreement(payable(this));
  }

  function testFailVoidAgreementWrongAddress() public {
    escrow.startEscrow{ value: 1 ether }(addr0, block.timestamp);
    escrow.voidAgreement(payable(this));
  }

  function testRecallFundsDeactivates() public {
    escrow.startEscrow{ value: 1 ether }(addr0, block.timestamp);
    escrow.recallFunds();

    assertFalse(escrow.isActive(address(this)));
  }

  function testRecallFundsValueSent() public {
    uint256 escrowValue = 1 ether;
    escrow.startEscrow{ value: escrowValue }(addr0, block.timestamp);
    uint256 balanceBefore = address(escrow).balance;

    escrow.recallFunds();
    uint256 balanceAfter = address(escrow).balance; 

    assertEq(balanceAfter, balanceBefore - escrowValue);
  }

  function testRecallFundsValueRecieved() public {
    uint256 escrowValue = 1 ether;
    escrow.startEscrow{ value: escrowValue }(addr0, block.timestamp);
    uint256 balanceBefore = address(this).balance;

    escrow.recallFunds();
    uint256 balanceAfter = address(this).balance; 

    assertEq(balanceAfter, balanceBefore + escrowValue);
  }

  function testFailRecallFundsNotActive() public {
    escrow.recallFunds();
  }

  function testFailRecallFundsTooSoon() public {
    escrow.startEscrow{ value: 1 ether }(addr0, block.timestamp + 1000);

    escrow.recallFunds();
  }

  function testFailRecallFundsWrongAddress() public {
    escrow.startEscrow{ value: 1 ether }(addr0, block.timestamp);

    vm.prank(addr0);
    escrow.recallFunds();
  }
}
