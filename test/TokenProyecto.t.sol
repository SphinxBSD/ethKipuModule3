// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import { TokenProyecto } from "../src/TokenProyecto.sol";

contract TokenProyectoTest is Test {
    // Declaration of local variables
    TokenProyecto token;
    address admin;
    address pauser;
    address minter;
    address user1;
    address user2;

    uint256 constant INITIAL_MINT = 1000 * 10**18;

    function setUp() public {
        admin = address(this);
        pauser = makeAddr("pauser");
        minter = makeAddr("minter");
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");

        token = new TokenProyecto(pauser, minter);
    }

    // Minting: success
    function testMintUnderCap() public {
        vm.startPrank(minter);
        token.mint(user1, INITIAL_MINT);
        vm.stopPrank();
        assertEq(token.totalSupply(), INITIAL_MINT);
        assertEq(token.balanceOf(user1), INITIAL_MINT);
    }

    // Minting: revert if over CAP
    function testMintOverCapShouldRevert() public {
        vm.startPrank(minter);
        token.mint(user1, token.CAP());
        vm.stopPrank();

        vm.expectRevert("CAP exceeded");
        vm.startPrank(minter);
        token.mint(user1, 1);
        vm.stopPrank();
    }

    // Roles: only MINTER_ROLE can mint
    function testOnlyMinterCanMint() public {
        vm.expectRevert(); // No role
        token.mint(user1, 100);
    }

    // Roles: only PAUSER_ROLE can pause/unpause
    function testOnlyPauserCanPauseUnpause() public {
        vm.startPrank(pauser);
        token.pause();
        vm.stopPrank();
        assertTrue(token.paused());

        vm.startPrank(pauser);
        token.unpause();
        vm.stopPrank();
        assertFalse(token.paused());
    }

    // Roles: should revert if not PAUSER_ROLE
    function testPauseByNonPauserShouldRevert() public {
        vm.expectRevert();
        token.pause();
    }

    function testUnpauseByNonPauserShouldRevert() public {
        vm.prank(pauser);
        token.pause();
        assertTrue(token.paused());

        vm.expectRevert();
        token.unpause();
    }

    // Transfers: transfer update balances
    function testTransfer() public {
        vm.startPrank(minter);
        token.mint(user1, INITIAL_MINT);
        vm.stopPrank();

        vm.startPrank(user1);
        token.transfer(user2, 500 * 10**18);
        vm.stopPrank();

        assertEq(token.balanceOf(user1), 500 * 10**18);
        assertEq(token.balanceOf(user2), 500 * 10**18);
    }

    // Allowances: approve + transferFrom success
    function testApproveAndTransferFrom() public {
        vm.startPrank(minter);
        token.mint(user1, INITIAL_MINT);
        vm.stopPrank();

        vm.startPrank(user1);
        token.approve(user2, 200 * 10**18);
        vm.stopPrank();

        vm.startPrank(user2);
        token.transferFrom(user1, user2, 200 * 10**18);
        vm.stopPrank();

        assertEq(token.balanceOf(user1), INITIAL_MINT - 200 * 10**18);
        assertEq(token.balanceOf(user2), 200 * 10**18);
    }

    // Allowances: transferFrom fails if allowance insufficient
    function testTransferFromFailsIfNoAllowance() public {
        vm.startPrank(minter);
        token.mint(user1, INITIAL_MINT);
        vm.stopPrank();

        vm.expectRevert();
        vm.prank(user2);
        token.transferFrom(user1, user2, 1);
    }

    // Allowances: transferFrom fails if balance insufficient
    function testTransferFromFailsIfNoBalance() public {
        vm.startPrank(user1);
        token.approve(user2, 100 * 10**18);
        vm.stopPrank();

        vm.expectRevert();
        vm.prank(user2);
        token.transferFrom(user1, user2, 100 * 10**18);
    }

    // Allowance modifiers
    function testIncreaseAllowance() public {
        vm.startPrank(user1);
        token.increaseAllowance(user2, 100);
        vm.stopPrank();
        assertEq(token.allowance(user1, user2), 100);

        vm.startPrank(user1);
        token.increaseAllowance(user2, 50);
        vm.stopPrank();
        assertEq(token.allowance(user1, user2), 150);
    }

    function testDecreaseAllowance() public {
        vm.prank(user1);
        token.increaseAllowance(user2, 100);

        vm.prank(user1);
        token.decreaseAllowance(user2, 40);
        assertEq(token.allowance(user1, user2), 60);
    }

    function testDecreaseAllowanceBelowZeroShouldRevert() public {
        vm.prank(user1);
        token.increaseAllowance(user2, 30);

        vm.expectRevert(); // Custom error
        vm.prank(user1);
        token.decreaseAllowance(user2, 50);
    }
}