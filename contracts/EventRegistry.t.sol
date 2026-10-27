// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import {Test} from "forge-std/Test.sol";
import {EventRegistry} from "./EventRegistry.sol";

/// @notice Unit test cho EventRegistry: happy path, revert path, event, fuzz.
contract EventRegistryTest is Test {
    EventRegistry internal reg;
    address internal alice = address(0xA11CE);
    address internal bob = address(0xB0B);
    address internal carol = address(0xCA201);

    // Khai báo lại event để dùng với vm.expectEmit
    event Registered(address indexed user, uint256 count);

    function setUp() public {
        reg = new EventRegistry(2); // owner = contract test này, sức chứa = 2
    }

    // ---------- 1. Happy path ----------
    function test_Register() public {
        vm.prank(alice);
        reg.register();
        assertTrue(reg.isRegistered(alice));
        assertEq(reg.registeredCount(), 1);
    }

    function test_OwnerCanSetCapacity() public {
        reg.setCapacity(10);
        assertEq(reg.capacity(), 10);
    }

    // ---------- 2. Revert path ----------
    function test_RevertWhen_RegisterTwice() public {
        vm.prank(alice);
        reg.register();
        vm.expectRevert(abi.encodeWithSelector(EventRegistry.AlreadyRegistered.selector, alice));
        vm.prank(alice);
        reg.register();
    }

    function test_RevertWhen_EventFull() public {
        vm.prank(alice);
        reg.register();
        vm.prank(bob);
        reg.register();
        vm.expectRevert(abi.encodeWithSelector(EventRegistry.EventFull.selector, 2));
        vm.prank(carol);
        reg.register();
    }

    function test_RevertWhen_NotOwnerSetsCapacity() public {
        vm.expectRevert(abi.encodeWithSelector(EventRegistry.NotOwner.selector, bob));
        vm.prank(bob);
        reg.setCapacity(5);
    }

    function test_RevertWhen_CapacityBelowRegistered() public {
        vm.prank(alice);
        reg.register();
        vm.prank(bob);
        reg.register();
        vm.expectRevert(abi.encodeWithSelector(EventRegistry.InvalidCapacity.selector, 1));
        reg.setCapacity(1);
    }

    function test_RevertWhen_DeployWithZeroCapacity() public {
        vm.expectRevert(abi.encodeWithSelector(EventRegistry.InvalidCapacity.selector, 0));
        new EventRegistry(0);
    }

    // ---------- 3. Event ----------
    function test_EmitsRegistered() public {
        vm.expectEmit(true, false, false, true, address(reg));
        emit Registered(alice, 1);
        vm.prank(alice);
        reg.register();
    }

    // ---------- 4. Fuzz ----------
    /// Hardhat gọi hàm này nhiều lần với newCapacity ngẫu nhiên
    function testFuzz_SetCapacity(uint256 newCapacity) public {
        vm.assume(newCapacity > 0);
        reg.setCapacity(newCapacity);
        assertEq(reg.capacity(), newCapacity);
    }

    /// Kẻ không phải owner, với bất kỳ địa chỉ nào, đều bị chặn
    function testFuzz_RevertWhen_AnyNonOwnerSetsCapacity(address caller) public {
        vm.assume(caller != address(this));
        vm.expectRevert(abi.encodeWithSelector(EventRegistry.NotOwner.selector, caller));
        vm.prank(caller);
        reg.setCapacity(5);
    }
}
