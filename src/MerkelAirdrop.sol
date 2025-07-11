// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { IERC20, SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
/**
 * @title Merkle Airdrop - Airdrop tokens to users who can prove they are in a merkle tree
 * @author Mrunal more
 */

contract MerkelAirdrop {
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


    constructor(bytes32 merkleRoot, IERC20 airdropToken) {
        i_merkleRoot = merkleRoot;
        i_airdropToken = airdropToken;
        }


    function claim(address account,  bytes32[] calldata merkleProof, uint256 amount, uint8 v, bytes32 r, bytes32 s) external {
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
        if (claimed[account]) {
            revert MerkelAirdrop__AlreadyClaim(); 
        }
        // check the signature
        if(!_isvalidSignature(account, getMessage(),  v, r, s)){
            revert MerkelAirdrop__InvalidSignature();
        }
        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert MerkelAirdrop__InvalidProof();
        }
        claimed[account] = true; // Mark as claimed
        emit claimToken(account, merkleProof, amount);

        i_airdropToken.transfer(account, amount);
    }

    function getMerkelRoot () external view returns(bytes32){
        return i_merkleRoot;
    }

    function getAirdropToken () external view returns(IERC20){
        return i_airdropToken;
    }

}