// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ImpactNFT} from "./ImpactNFT.sol";
import {ImpactNFTImplementation} from "./ImpactNFTImplementation.sol";

contract ImpactNFTFactory {
    uint256 public _nextIndex;
    mapping(uint256 => address) public ImapactNFTs;

    function CreateImpactNFT(
        uint maxSupply,
        uint unitPrice,
        address receiver,
        address defaultAdmin,
        string memory defaultMetadataURI
    ) public returns (address impactNFTInstance) {
        ImpactNFT instance = new ImpactNFT();
        address _instance = address(instance);
        ImpactNFTImplementation _contract = ImpactNFTImplementation(_instance);
        _contract.initialize(
            maxSupply,
            unitPrice,
            receiver,
            defaultAdmin,
            defaultMetadataURI
        );

        uint256 index = _nextIndex++;
        ImapactNFTs[index] = _instance;

        return _instance;
    }
}
