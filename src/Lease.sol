// SPDX-License-Identifier: MIT
pragma solidity 0.7.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./base/ERC721Base.sol";

contract Lease is ERC721Base {
    // -----------------------------------------
    // Storage
    // -----------------------------------------

    mapping(uint256 => address) internal _agreements;

    // -----------------------------------------
    // Events
    // -----------------------------------------

    event LeaseAgreement(
        IERC721 indexed tokenContract,
        uint256 indexed tokenID,
        address indexed user,
        address agreement
    );

    // -----------------------------------------
    // External functions
    // -----------------------------------------

    function setLease(
        IERC721 tokenContract,
        uint256 tokenID,
        address newUser,
        address newAgreement
    ) external {
        uint256 lease = _leaseID(tokenContract, tokenID);
        address tokenOwner = tokenContract.ownerOf(tokenID);
        address leaseOwner = _ownerOf(lease);
        if (leaseOwner != address(0)) {
            address agreement = _agreements[lease];
            if (agreement != address(0)) {
                require(msg.sender == agreement, "NOT_AUTHORIZED_AGREEMENT");
            } else {
                require(msg.sender == tokenOwner || _operatorsForAll[tokenOwner][msg.sender], "NOT_AUTHORIZED"); // TODO consider not giving that power to operators ?
            }
            if (leaseOwner != newUser) {
                _transferFrom(leaseOwner, newUser, lease);
                _agreements[lease] = newAgreement;
            }
            emit LeaseAgreement(tokenContract, tokenID, newUser, newAgreement);
        } else {
            require(msg.sender == tokenOwner || _operatorsForAll[tokenOwner][msg.sender], "NOT_AUTHORIZED"); // TODO consider not giving that power to operators ?
            _transferFrom(address(0), newUser, lease);
            _agreements[lease] = newAgreement;
            emit LeaseAgreement(tokenContract, tokenID, newUser, newAgreement);
        }
    }

    function voidLease(IERC721 tokenContract, uint256 tokenID) external {
        uint256 lease = _leaseID(tokenContract, tokenID);
        address leaseOwner = _ownerOf(lease);
        require(leaseOwner != address(0), "NO_EXIST");
        address agreement = _agreements[lease];
        if (agreement != address(0)) {
            require(msg.sender == agreement, "NOT_AUTHORIZED_AGREEMENT");
        } else {
            address tokenOwner = tokenContract.ownerOf(tokenID);
            require(
                msg.sender == leaseOwner ||
                    _operatorsForAll[leaseOwner][msg.sender] ||
                    msg.sender == tokenOwner ||
                    _operatorsForAll[tokenOwner][msg.sender],
                "NOT_AUTHORIZED"
            );
        }
        emit LeaseAgreement(tokenContract, tokenID, address(0), address(0));
        _burn(leaseOwner, lease);
        _breakSubLease(lease);
    }

    function isLeased(IERC721 tokenContract, uint256 tokenID) external view returns (bool) {
        return _ownerOf(_leaseID(tokenContract, tokenID)) != address(0);
    }

    function currentUser(IERC721 tokenContract, uint256 tokenID) external view returns (address) {
        uint256 lease = _leaseID(tokenContract, tokenID);
        address leaseOwner = _ownerOf(lease);
        if (leaseOwner != address(0)) {
            return _finalLeaseOwner(lease, leaseOwner);
        } else {
            return tokenContract.ownerOf(tokenID);
        }
    }

    function leaseID(IERC721 tokenContract, uint256 tokenID) external view returns (uint256) {
        return _leaseID(tokenContract, tokenID);
    }

    // -----------------------------------------
    // Internal Functions
    // -----------------------------------------

    function _leaseID(IERC721 tokenContract, uint256 tokenID) internal view returns (uint256) {
        uint256 baseId = uint256(keccak256(abi.encodePacked(tokenContract, tokenID))) &
            0x1FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        if (tokenContract == this) {
            uint256 depth = ((tokenID >> 253) + 1);
            require(depth < 8, "INVALID_LEASE_MAX_DEPTH_8");
            return baseId | (depth << 253);
        }
        return baseId;
    }

    function _finalLeaseOwner(uint256 lease, address lastLeaseOwner) internal view returns (address) {
        uint256 subLease = _leaseID(this, lease);
        address subLeaseOwner = _ownerOf(subLease);
        if (subLeaseOwner != address(0)) {
            return _finalLeaseOwner(subLease, subLeaseOwner);
        } else {
            return lastLeaseOwner;
        }
    }

    function _breakSubLease(uint256 lease) internal {
        uint256 subLease = _leaseID(this, lease);
        address subLeaseOwner = _ownerOf(subLease);
        if (subLeaseOwner != address(0)) {
            emit LeaseAgreement(this, lease, address(0), address(0));
            _burn(subLeaseOwner, subLease);
            _breakSubLease(subLease);
        }
    }
}
