// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

/// @title EventRegistry — demo cho IS355 Session 7 G01
/// @notice Owner tạo một sự kiện có sức chứa giới hạn; người dùng tự đăng ký.
/// @dev Minh họa: access control (onlyOwner), custom errors, events,
///      checks-effects pattern, và không dùng tx.origin.
contract EventRegistry {
    address public immutable owner;
    uint256 public capacity;
    uint256 public registeredCount;
    mapping(address => bool) public isRegistered;

    error NotOwner(address caller);
    error AlreadyRegistered(address user);
    error EventFull(uint256 capacity);
    error InvalidCapacity(uint256 requested);

    event Registered(address indexed user, uint256 count);
    event CapacityChanged(uint256 oldCapacity, uint256 newCapacity);

    constructor(uint256 initialCapacity) {
        if (initialCapacity == 0) revert InvalidCapacity(initialCapacity);
        owner = msg.sender;
        capacity = initialCapacity;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner(msg.sender); // msg.sender, không phải tx.origin
        _;
    }

    function register() external {
        // Checks
        if (isRegistered[msg.sender]) revert AlreadyRegistered(msg.sender);
        if (registeredCount >= capacity) revert EventFull(capacity);
        // Effects
        isRegistered[msg.sender] = true;
        registeredCount += 1;
        emit Registered(msg.sender, registeredCount);
        // (Không có Interactions: không gọi ra contract ngoài)
    }

    function setCapacity(uint256 newCapacity) external onlyOwner {
        if (newCapacity == 0 || newCapacity < registeredCount) revert InvalidCapacity(newCapacity);
        emit CapacityChanged(capacity, newCapacity);
        capacity = newCapacity;
    }
}
