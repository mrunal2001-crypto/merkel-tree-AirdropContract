// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { IERC20, SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import { EIP712 } from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
/**
 * @title Merkle Airdrop - Airdrop tokens to users who can prove they are in a merkle tree
 * @author Mrunal more
 */

contract MerkelAirdrop is EIP712 {
    using SafeERC20 for IERC20;

    error MerkelAirdrop__InvalidProof();
    error MerkelAirdrop__InvalidSignature();

    event claimToken(address indexed account, bytes32[] merkleProof, uint256 amount);
    error MerkelAirdrop__AlreadyClaim();

    address [] claimers;
    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airdropToken;
     mapping(address => bool) private claimed;
//    mapping(address => uint256) private claimedAmounts; // Uncomment if you want to track claimed amounts

    bytes32 public constant MESSage_TYPEHASH = keccak256("AirdropClaim(address account,uint256 amount)");

    struct AirdropClaim {
        address account;
        uint256 amount;
    }


    constructor(bytes32 merkleRoot, IERC20 airdropToken) EIP712("MerkelAirdrop", "1") {
        i_merkleRoot = merkleRoot;
        i_airdropToken = airdropToken;
        }


    function claim(address account,  bytes32[] calldata merkleProof, uint256 amount, uint8 v, bytes32 r, bytes32 s) external {
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
        if (claimed[account]) {
            revert MerkelAirdrop__AlreadyClaim(); 
        }
        // check the signature
        if(!_isvalidSignature(account, getMessageHash(account, amount),  v, r, s)){
            revert MerkelAirdrop__InvalidSignature();
        }
        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert MerkelAirdrop__InvalidProof();
        }
        claimed[account] = true; // Mark as claimed
        emit claimToken(account, merkleProof, amount);

        i_airdropToken.transfer(account, amount);
    }

    //This function is creating a typed structured hash for an airdrop claim using the EIP-712 standard. Here's what it does step by step:

    function getMessageHash(address account, uint256 amount) public view returns (bytes32) {
       return _hashTypedDataV4(keccak256(abi.encode(
           MESSage_TYPEHASH, AirdropClaim({
               account: account,
               amount: amount
           })
        ))); 
    }

    function getMerkelRoot () external view returns(bytes32){
        return i_merkleRoot;
    }

    function getAirdropToken () external view returns(IERC20){
        return i_airdropToken;
    }

    function _isvalidSignature(address account, bytes32 digest, uint8 v, bytes32 r, bytes32 s) internal pure returns (bool) {
        (address actualSigner, ,) = ECDSA.tryRecover(digest, v, r, s);
        return actualSigner == account;
    }

}