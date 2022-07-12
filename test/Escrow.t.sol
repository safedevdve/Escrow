// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/Escrow.sol";

contract ContractTest is Test {
  Escrow escrow;
  address addr0;

  function setUp() public {
    addr0 = 0x2DD0e7C4EfF32E33f5fcaeE2aadC99C691134bB5;
    escrow = new Escrow();
  }

  function testStartEscrowActive() public {
    escrow.startEscrow{ value: 1 ether }(addr0, 1 days);
    assertTrue(escrow.isActive(address(this)));
  }

  function testStartEscrowValuesAccurate() public {
    escrow.startEscrow{ value: 1 ether }(addr0, 1 days);
    
    assertEq(escrow.getSeller(address(this)), addr0);
    assertEq(escrow.getAmount(address(this)), 1 ether);
    assertEq(escrow.getTimeLimit(address(this)), 1 days);
  }
}
