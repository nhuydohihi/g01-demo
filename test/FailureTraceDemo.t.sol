// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import {Test} from "forge-std/Test.sol";
import {EventRegistry} from "../contracts/EventRegistry.sol";

/// @notice TEST CỐ Ý FAIL — chỉ dùng để demo failure trace.
/// Mặc định test này được bỏ qua (skip) để `pnpm test` luôn xanh.
/// Bật bằng biến môi trường: DEMO_FAIL=true pnpm test:trace
contract FailureTraceDemo is Test {
    function test_DEMO_NonOwnerSetsCapacity_ShouldFail() public {
        vm.skip(!vm.envOr("DEMO_FAIL", false));
        EventRegistry reg = new EventRegistry(2);
        vm.prank(address(0xB0B));   // bob không phải owner
        reg.setCapacity(5);         // → revert NotOwner(bob) → test fail
    }
}
