// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract ImpactNFTImplementation is ERC721, ERC721Enumerable, AccessControl {
    error TransferError();
    error SupplyExceeded();
    error AlreadyInitalized();

    address public _receiver;
    uint256 public _maxSupply;
    uint256 public _unitPrice;
    uint256 public _initBlock;
    uint256 public _nextTokenId;
    bytes32 public constant SETTER_ROLE = keccak256("SETTER_ROLE");
    ERC20 public constant USDC =
        ERC20(0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913);

    string public DEFAULT_METADATA;
    mapping(uint => string) public metadata;

    constructor() ERC721("ImpactNFT", "iNFT") {}

    function initialize(
        uint maxSupply,
        uint unitPrice,
        address receiver,
        address defaultAdmin,
        string memory defaultMetadataURI
    ) public {
        if (_initBlock != 0) revert AlreadyInitalized();

        _receiver = receiver;
        _maxSupply = maxSupply;
        _unitPrice = unitPrice;
        _initBlock = block.number;

        DEFAULT_METADATA = defaultMetadataURI;

        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(SETTER_ROLE, defaultAdmin);
    }

    function mintBatch(uint quantity) public {
        uint totalPrice = _unitPrice * quantity;
        if (totalSupply() + quantity > _maxSupply) revert SupplyExceeded();

        if (!USDC.transferFrom(msg.sender, _receiver, totalPrice))
            revert TransferError();

        for (uint i = 0; i < quantity; i++) {
            uint256 tokenId = _nextTokenId++;
            _safeMint(msg.sender, tokenId);
        }
    }

    function setMetadata(
        uint tokenId,
        string memory newURI
    ) public onlyRole(SETTER_ROLE) {
        _setMetadata(tokenId, newURI);
    }

    function setBatchURI(
        uint[] memory tokenIds,
        string[] memory newURIs
    ) public onlyRole(SETTER_ROLE) {
        for (uint i = 0; i < tokenIds.length; i++) {
            _setMetadata(tokenIds[i], newURIs[i]);
        }
    }

    function _setMetadata(uint tokenId, string memory newURI) internal {
        metadata[tokenId] = newURI;
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        string memory _tokenURI = metadata[tokenId];
        return bytes(_tokenURI).length != 0 ? _tokenURI : DEFAULT_METADATA;
    }

    // The following functions are overrides required by Solidity.

    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal override(ERC721, ERC721Enumerable) returns (address) {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(
        address account,
        uint128 value
    ) internal override(ERC721, ERC721Enumerable) {
        super._increaseBalance(account, value);
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(ERC721, ERC721Enumerable, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
