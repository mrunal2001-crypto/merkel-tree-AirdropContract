// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MerkelAirdrop} from "../src/MerkelAirdrop.sol";
import {BagelToken} from "../src/BagelToken.sol";
import {Test, console} from "forge-std/Test.sol";

contract MerkelAirdropTest is Test {
  MerkelAirdrop public airdrop;
  BagelToken public token;

  bytes32 public ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
  uint256 public AMOUNT_TO_Claim = 25 * 1e18; // 1000 tokens with 18 decimals
  uint256 public AMOUNT_TO_SEND = AMOUNT_TO_Claim * 4; // 25 tokens with 18 decimals
  bytes32  proof1 = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
  bytes32  proof2 = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
  bytes32[] public merkleProof = [proof1,proof2];
  address user;
  uint256 userprivkey;
  address gasPayer;


      function setUp() public {
        token = new BagelToken();
        airdrop = new MerkelAirdrop(ROOT, token);
        // Mint tokens to the airdrop contract
        token.mint(token.owner(), AMOUNT_TO_SEND); 
        token.transfer(address(airdrop), AMOUNT_TO_SEND);

        (user,userprivkey) = makeAddrAndKey("user");
        gasPayer = makeAddr("gasPayer");
      }

    function testClaim() public {
        uint256 startingBalance = token.balanceOf(user);
        bytes32 digest = airdrop.getMessageHash(user, AMOUNT_TO_Claim);

       
        // Sign the claim message
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userprivkey, digest);

        vm.prank(gasPayer);
        airdrop.claim(user, merkleProof, AMOUNT_TO_Claim, v, r, s);

        uint256 endingBalance = token.balanceOf(user);
        console.log("Starting Balance:", startingBalance);
        console.log("Ending Balance:", endingBalance);
        assertEq(endingBalance, startingBalance + AMOUNT_TO_Claim, "User should receive the correct amount of tokens");
        vm.stopPrank();
    }
}