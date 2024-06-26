// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ImpactNFT {
    error InvalidImplementation();

    address public constant ImpactNFTImplementation =
        0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913;  // ToDo: set actual implementation contract address

    fallback() external {
        address impl = ImpactNFTImplementation;
        if (impl == address(0)) revert InvalidImplementation();

        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), impl, ptr, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(ptr, 0, size)
            switch result
            case 0 {
                revert(ptr, size)
            }
            default {
                return(ptr, size)
            }
        }
    }
}
