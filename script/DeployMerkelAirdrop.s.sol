// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import { Script } from "forge-std/Script.sol";
import { MerkelAirdrop } from "../src/MerkelAirdrop.sol";
import { BagelToken } from "../src/BagelToken.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeployMerkelAirdrop is Script {
bytes32 private merkleRoot = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
uint256 private s_amout_to_transfer = 25 * 1e18; // 25 tokens with 18 decimals

    function deployMerkelAirdrop() public returns( MerkelAirdrop, BagelToken) {
        vm.startBroadcast();

        // Deploy the BagelToken contract
        BagelToken bagelToken = new BagelToken();
        MerkelAirdrop airdrop = new MerkelAirdrop(merkleRoot, IERC20(address(bagelToken)));
        // Mint tokens to the airdrop contract
        bagelToken.mint(bagelToken.owner(), s_amout_to_transfer * 4);
        bagelToken.transfer(address(airdrop), s_amout_to_transfer * 4);

        vm.stopBroadcast();
        return (airdrop, bagelToken);
    }

    function run() external returns(MerkelAirdrop, BagelToken){
        return deployMerkelAirdrop();
    }
}