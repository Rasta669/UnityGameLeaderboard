// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "../src/Leaderboard.sol";

contract LeaderboardTest is Test {
    Leaderboard public leaderboard;
    address public player1;
    address public player2;
    address public player3;

    function setUp() public {
        leaderboard = new Leaderboard();
        player1 = makeAddr("player1");
        player2 = makeAddr("player2");
        player3 = makeAddr("player3");
    }

    function testSubmitScore() public {
        vm.startPrank(player1);
        leaderboard.setPlayerName("Player One");
        leaderboard.submitScore(100);
        vm.stopPrank();

        vm.startPrank(player2);
        leaderboard.setPlayerName("Player Two");
        leaderboard.submitScore(200);
        vm.stopPrank();

        vm.startPrank(player3);
        leaderboard.setPlayerName("Player Three");
        leaderboard.submitScore(300);
        vm.stopPrank();

        // Check scores
        assertEq(leaderboard.getScoreByPosition(0), 300);
        assertEq(leaderboard.getScoreByPosition(1), 200);
        assertEq(leaderboard.getScoreByPosition(2), 100);

        // Check player names
        assertEq(leaderboard.getPlayerName(player1), "Player One");
        assertEq(leaderboard.getPlayerName(player2), "Player Two");
        assertEq(leaderboard.getPlayerName(player3), "Player Three");

        // Check player addresses by name
        assertEq(leaderboard.getPlayerAddressByName("Player One"), player1);
        assertEq(leaderboard.getPlayerAddressByName("Player Two"), player2);
        assertEq(leaderboard.getPlayerAddressByName("Player Three"), player3);
    }

    function testUpdatePlayerName() public {
        vm.startPrank(player1);
        leaderboard.setPlayerName("Original Name");
        leaderboard.submitScore(100);

        // Update name
        leaderboard.setPlayerName("Updated Name");
        vm.stopPrank();

        assertEq(leaderboard.getPlayerName(player1), "Updated Name");
        assertEq(leaderboard.getPlayerAddressByName("Updated Name"), player1);
        assertEq(
            leaderboard.getPlayerAddressByName("Original Name"),
            address(0)
        );
    }

    function testMaxScores() public {
        // Submit scores from 100 different players
        for (uint256 i = 0; i < 100; i++) {
            address player = makeAddr(
                string(abi.encodePacked("player", vm.toString(i)))
            );
            vm.startPrank(player);
            string memory playerName = string(
                abi.encodePacked("Player ", vm.toString(i))
            );
            leaderboard.setPlayerName(playerName);
            leaderboard.submitScore((i + 1) * 10);
            vm.stopPrank();
        }

        // Verify we have exactly MAX_SCORES entries
        assertEq(leaderboard.getTopScores().length, 100);

        // Submit a new score from a new player
        address newPlayer = makeAddr("newPlayer");
        vm.startPrank(newPlayer);
        leaderboard.setPlayerName("New Player");
        leaderboard.submitScore(1000); // This should be the highest score
        vm.stopPrank();

        // Verify the new score is at the top (position 0)
        assertEq(leaderboard.getScoreByPosition(0), 1000);
        assertEq(leaderboard.getScoreByPosition(1), 1000);
        assertEq(leaderboard.getPlayerNameByPosition(1), "New Player");
        assertEq(leaderboard.getTopScores().length, 100); // Still at max length

        // Verify that the lowest score (from Player 0 with score 10) was removed
        // and the new lowest score is from Player 1 with score 20
        assertEq(leaderboard.getScoreByPosition(99), 20);
        assertEq(leaderboard.getPlayerNameByPosition(99), "Player 1");
    }

    function testInvalidScore() public {
        vm.startPrank(player1);
        leaderboard.setPlayerName("Player One");

        // Try to submit score of 0
        vm.expectRevert("Score must be greater than 0");
        leaderboard.submitScore(0);

        // Try to submit empty name
        vm.expectRevert("Player name cannot be empty");
        leaderboard.setPlayerName("");

        // Try to submit name that's too long
        string
            memory longName = "This name is way too long and should exceed the maximum length allowed by the contract";
        vm.expectRevert("Player name too long");
        leaderboard.setPlayerName(longName);

        vm.stopPrank();
    }

    function testGetPlayerNames() public {
        vm.startPrank(player1);
        leaderboard.setPlayerName("Player One");
        leaderboard.submitScore(100);
        vm.stopPrank();

        vm.startPrank(player2);
        leaderboard.setPlayerName("Player Two");
        leaderboard.submitScore(200);
        vm.stopPrank();

        vm.startPrank(player3);
        leaderboard.setPlayerName("Player Three");
        leaderboard.submitScore(300);
        vm.stopPrank();

        string[] memory names = leaderboard.getPlayerNames();
        assertEq(names.length, 3);
        assertEq(names[0], "Player Three");
        assertEq(names[1], "Player Two");
        assertEq(names[2], "Player One");
    }

    function testGetPlayerNamesInRange() public {
        vm.startPrank(player1);
        leaderboard.setPlayerName("Player One");
        leaderboard.submitScore(100);
        vm.stopPrank();

        vm.startPrank(player2);
        leaderboard.setPlayerName("Player Two");
        leaderboard.submitScore(200);
        vm.stopPrank();

        vm.startPrank(player3);
        leaderboard.setPlayerName("Player Three");
        leaderboard.submitScore(300);
        vm.stopPrank();

        string[] memory names = leaderboard.getPlayerNamesInRange(0, 2);
        assertEq(names.length, 2);
        assertEq(names[0], "Player Three");
        assertEq(names[1], "Player Two");
    }

    function testGetPlayerNameByPosition() public {
        vm.startPrank(player1);
        leaderboard.setPlayerName("Player One");
        leaderboard.submitScore(100);
        vm.stopPrank();

        vm.startPrank(player2);
        leaderboard.setPlayerName("Player Two");
        leaderboard.submitScore(200);
        vm.stopPrank();

        assertEq(leaderboard.getPlayerNameByPosition(0), "Player Two");
        assertEq(leaderboard.getPlayerNameByPosition(1), "Player One");
        assertEq(leaderboard.getPlayerNameByPosition(2), ""); // Invalid position
    }

    function testGetScores() public {
        vm.startPrank(player1);
        leaderboard.setPlayerName("Player One");
        leaderboard.submitScore(100);
        vm.stopPrank();

        vm.startPrank(player2);
        leaderboard.setPlayerName("Player Two");
        leaderboard.submitScore(200);
        vm.stopPrank();

        uint256[] memory scoreValues = leaderboard.getScores();
        assertEq(scoreValues.length, 2);
        assertEq(scoreValues[0], 200);
        assertEq(scoreValues[1], 100);
    }

    function testGetPlayerByPosition() public {
        vm.startPrank(player1);
        leaderboard.setPlayerName("Player One");
        leaderboard.submitScore(100);
        vm.stopPrank();

        vm.startPrank(player2);
        leaderboard.setPlayerName("Player Two");
        leaderboard.submitScore(200);
        vm.stopPrank();

        assertEq(leaderboard.getPlayerByPosition(0), player2);
        assertEq(leaderboard.getPlayerByPosition(1), player1);
        assertEq(leaderboard.getPlayerByPosition(2), address(0)); // Invalid position
    }

    function testGetTimestampByPosition() public {
        vm.startPrank(player1);
        leaderboard.setPlayerName("Player One");
        leaderboard.submitScore(100);
        vm.stopPrank();

        vm.startPrank(player2);
        leaderboard.setPlayerName("Player Two");
        leaderboard.submitScore(200);
        vm.stopPrank();

        uint256 timestamp1 = leaderboard.getTimestampByPosition(0);
        uint256 timestamp2 = leaderboard.getTimestampByPosition(1);
        assertTrue(timestamp1 > 0);
        assertTrue(timestamp2 > 0);
        assertTrue(timestamp1 >= timestamp2); // First score should be newer or same time
        assertEq(leaderboard.getTimestampByPosition(2), 0); // Invalid position
    }

    function testScoreUpdates() public {
        vm.startPrank(player1);
        leaderboard.setPlayerName("Player One");

        // Submit initial score
        leaderboard.submitScore(100);
        assertEq(leaderboard.getPlayerScore(player1), 100);

        // Submit lower score (should be ignored)
        leaderboard.submitScore(50);
        assertEq(leaderboard.getPlayerScore(player1), 100);

        // Submit higher score (should update)
        leaderboard.submitScore(200);
        assertEq(leaderboard.getPlayerScore(player1), 200);
        vm.stopPrank();
    }

    function testMultipleScoreUpdates() public {
        vm.startPrank(player1);
        leaderboard.setPlayerName("Player One");

        // Submit multiple increasing scores
        leaderboard.submitScore(100);
        leaderboard.submitScore(200);
        leaderboard.submitScore(300);
        leaderboard.submitScore(400);

        // Verify only the highest score is kept
        assertEq(leaderboard.getPlayerScore(player1), 400);
        assertEq(leaderboard.getTopScores().length, 1);
        assertEq(leaderboard.getScoreByPosition(0), 400);
        vm.stopPrank();
    }

    function testEmptyLeaderboard() public {
        // Test getters with empty leaderboard
        assertEq(leaderboard.getTopScores().length, 0);
        assertEq(leaderboard.getScores().length, 0);
        assertEq(leaderboard.getPlayerNames().length, 0);
        assertEq(leaderboard.getScoreByPosition(0), 0);
        assertEq(leaderboard.getPlayerByPosition(0), address(0));
        assertEq(leaderboard.getPlayerNameByPosition(0), "");
        assertEq(leaderboard.getTimestampByPosition(0), 0);
    }

    function testInvalidRangeQueries() public {
        vm.startPrank(player1);
        leaderboard.setPlayerName("Player One");
        leaderboard.submitScore(100);
        vm.stopPrank();

        vm.startPrank(player2);
        leaderboard.setPlayerName("Player Two");
        leaderboard.submitScore(200);
        vm.stopPrank();

        // Test invalid range (start >= end)
        vm.expectRevert("Start position must be less than end position");
        leaderboard.getPlayerNamesInRange(1, 1);

        // Test range exceeding leaderboard length
        vm.expectRevert("End position exceeds leaderboard length");
        leaderboard.getPlayerNamesInRange(0, 3);
    }

    function testScoreRemovalOnUpdate() public {
        // Add multiple players
        vm.startPrank(player1);
        leaderboard.setPlayerName("Player One");
        leaderboard.submitScore(100);
        vm.stopPrank();

        vm.startPrank(player2);
        leaderboard.setPlayerName("Player Two");
        leaderboard.submitScore(200);
        vm.stopPrank();

        vm.startPrank(player3);
        leaderboard.setPlayerName("Player Three");
        leaderboard.submitScore(300);
        vm.stopPrank();

        // Update player1's score
        vm.startPrank(player1);
        leaderboard.submitScore(400);
        vm.stopPrank();

        // Verify player1's old score was removed and new score is at the top
        assertEq(leaderboard.getTopScores().length, 3);
        assertEq(leaderboard.getScoreByPosition(0), 400);
        assertEq(leaderboard.getPlayerByPosition(0), player1);
        assertEq(leaderboard.getScoreByPosition(1), 300);
        assertEq(leaderboard.getScoreByPosition(2), 200);
    }
}
