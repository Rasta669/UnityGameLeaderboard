// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Script.sol";
import "../src/Leaderboard.sol";

contract LeaderboardScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        Leaderboard leaderboard = new Leaderboard();

        vm.stopBroadcast();

        // Log the deployed address
        console2.log("Leaderboard deployed to:", address(leaderboard));
    }
}
