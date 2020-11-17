// SPDX-License-Identifier: MIT
pragma solidity 0.7.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract ERC721Users {
    // -----------------------------------------
    // Storage
    // -----------------------------------------

    mapping(bytes32 => address) internal _users;
    mapping(address => mapping(address => bool)) internal _operatorsForAll;
    mapping(bytes32 => address) internal _agreements;

    // -----------------------------------------
    // Events
    // -----------------------------------------

    event User(IERC721 indexed tokenContract, uint256 indexed tokenID, address indexed user, address agreement);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    // -----------------------------------------
    // External Functions
    // -----------------------------------------

    function userOf(IERC721 tokenContract, uint256 tokenID) external view returns (address) {
        address user = _users[_id(tokenContract, tokenID)];
        if (user != address(0)) {
            return user;
        }
        return tokenContract.ownerOf(tokenID);
    }

    function agreementFor(IERC721 tokenContract, uint256 tokenID) external view returns (address) {
        return _agreements[_id(tokenContract, tokenID)];
    }

    function setUser(
        IERC721 tokenContract,
        uint256 tokenID,
        address newUser,
        address newAgreement
    ) external {
        if (newUser == address(0)) {
            require(newAgreement == address(0), "NO_USER_NO_AGREEMENT");
        }
        address owner = tokenContract.ownerOf(tokenID);
        bytes32 id = _id(tokenContract, tokenID);
        address agreement = _agreements[id];
        if (agreement != address(0)) {
            require(msg.sender == agreement, "NOT_AUTHORIZED_AGREEMENT");
        } else {
            require(msg.sender == owner || _operatorsForAll[owner][msg.sender], "NOT_AUTHORIZED");
        }
        _users[id] = newUser;
        _agreements[id] = newAgreement;
        emit User(tokenContract, tokenID, newUser, newAgreement);
    }

    function setApprovalForAll(address operator, bool approved) external {
        _operatorsForAll[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    // -----------------------------------------
    // Internal Functions
    // -----------------------------------------

    function _id(IERC721 tokenContract, uint256 tokenID) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(tokenContract, tokenID));
    }
}
