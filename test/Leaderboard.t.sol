// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "../src/Leaderboard.sol";

contract LeaderboardTest is Test {
    Leaderboard public leaderboard;
    address public alice = makeAddr("alice");
    address public bob = makeAddr("bob");
    address public charlie = makeAddr("charlie");

    function setUp() public {
        leaderboard = new Leaderboard();
        vm.deal(alice, 1 ether);
        vm.deal(bob, 1 ether);
        vm.deal(charlie, 1 ether);
    }

    function testSubmitScore() public {
        vm.startPrank(alice);
        leaderboard.setPlayerName("Player One");
        leaderboard.submitScore(100);
        vm.stopPrank();

        vm.startPrank(bob);
        leaderboard.setPlayerName("Player Two");
        leaderboard.submitScore(200);
        vm.stopPrank();

        vm.startPrank(charlie);
        leaderboard.setPlayerName("Player Three");
        leaderboard.submitScore(300);
        vm.stopPrank();

        // Check scores
        assertEq(leaderboard.getScoreByPosition(0), 300);
        assertEq(leaderboard.getScoreByPosition(1), 200);
        assertEq(leaderboard.getScoreByPosition(2), 100);

        // Check player names
        assertEq(leaderboard.getPlayerName(alice), "Player One");
        assertEq(leaderboard.getPlayerName(bob), "Player Two");
        assertEq(leaderboard.getPlayerName(charlie), "Player Three");

        // Check player addresses by name
        assertEq(leaderboard.getPlayerAddressByName("Player One"), alice);
        assertEq(leaderboard.getPlayerAddressByName("Player Two"), bob);
        assertEq(leaderboard.getPlayerAddressByName("Player Three"), charlie);
    }

    function testUpdatePlayerName() public {
        vm.startPrank(alice);

        // First name set should work
        leaderboard.setPlayerName("Original Name");
        assertEq(leaderboard.getPlayerName(alice), "Original Name");

        // Second name set should be ignored
        leaderboard.setPlayerName("Updated Name");
        assertEq(leaderboard.getPlayerName(alice), "Original Name");

        vm.stopPrank();
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
        assertEq(leaderboard.getPlayerByPosition(1), newPlayer);
        assertEq(leaderboard.getTopScores().length, 100); // Still at max length

        // Verify that the lowest score was removed
        assertEq(leaderboard.getScoreByPosition(99), 20);
    }

    function testInvalidScore() public {
        vm.startPrank(alice);

        // Try to submit empty name (should be ignored, not revert)
        leaderboard.setPlayerName("");
        assertEq(bytes(leaderboard.getPlayerName(alice)).length, 0);

        // Try to submit name that's too long (should revert)
        string
            memory longName = "This name is way too long and should exceed the maximum length allowed by the contract";
        vm.expectRevert("Player name too long");
        leaderboard.setPlayerName(longName);

        // Try to submit score of 0 (should revert)
        vm.expectRevert("Score must be greater than 0");
        leaderboard.submitScore(0);

        vm.stopPrank();
    }

    function testGetPlayerNames() public {
        vm.startPrank(alice);
        leaderboard.setPlayerName("Player One");
        leaderboard.submitScore(100);
        vm.stopPrank();

        vm.startPrank(bob);
        leaderboard.setPlayerName("Player Two");
        leaderboard.submitScore(200);
        vm.stopPrank();

        vm.startPrank(charlie);
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
        vm.startPrank(alice);
        leaderboard.setPlayerName("Player One");
        leaderboard.submitScore(100);
        vm.stopPrank();

        vm.startPrank(bob);
        leaderboard.setPlayerName("Player Two");
        leaderboard.submitScore(200);
        vm.stopPrank();

        vm.startPrank(charlie);
        leaderboard.setPlayerName("Player Three");
        leaderboard.submitScore(300);
        vm.stopPrank();

        string[] memory names = leaderboard.getPlayerNamesInRange(0, 2);
        assertEq(names.length, 2);
        assertEq(names[0], "Player Three");
        assertEq(names[1], "Player Two");
    }

    function testGetPlayerNameByPosition() public {
        vm.startPrank(alice);
        leaderboard.setPlayerName("Alice");
        leaderboard.submitScore(100);
        vm.stopPrank();

        vm.startPrank(bob);
        leaderboard.setPlayerName("Bob");
        leaderboard.submitScore(200);
        vm.stopPrank();

        // Verify names are returned in score order
        assertEq(leaderboard.getPlayerNameByPosition(0), "Bob"); // Higher score
        assertEq(leaderboard.getPlayerNameByPosition(1), "Alice"); // Lower score
        assertEq(leaderboard.getPlayerNameByPosition(2), ""); // Invalid position
    }

    function testGetScores() public {
        vm.startPrank(alice);
        leaderboard.setPlayerName("Player One");
        leaderboard.submitScore(100);
        vm.stopPrank();

        vm.startPrank(bob);
        leaderboard.setPlayerName("Player Two");
        leaderboard.submitScore(200);
        vm.stopPrank();

        uint256[] memory scoreValues = leaderboard.getScores();
        assertEq(scoreValues.length, 2);
        assertEq(scoreValues[0], 200);
        assertEq(scoreValues[1], 100);
    }

    function testGetPlayerByPosition() public {
        vm.startPrank(alice);
        leaderboard.setPlayerName("Player One");
        leaderboard.submitScore(100);
        vm.stopPrank();

        vm.startPrank(bob);
        leaderboard.setPlayerName("Player Two");
        leaderboard.submitScore(200);
        vm.stopPrank();

        assertEq(leaderboard.getPlayerByPosition(0), bob);
        assertEq(leaderboard.getPlayerByPosition(1), alice);
        assertEq(leaderboard.getPlayerByPosition(2), address(0)); // Invalid position
    }

    function testGetTimestampByPosition() public {
        vm.startPrank(alice);
        leaderboard.setPlayerName("Player One");
        leaderboard.submitScore(100);
        vm.stopPrank();

        vm.startPrank(bob);
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
        vm.startPrank(alice);
        leaderboard.setPlayerName("Player One");

        // Submit initial score
        leaderboard.submitScore(100);
        assertEq(leaderboard.getPlayerScore(alice), 100);

        // Submit lower score (should be ignored)
        leaderboard.submitScore(50);
        assertEq(leaderboard.getPlayerScore(alice), 100);

        // Submit higher score (should update)
        leaderboard.submitScore(200);
        assertEq(leaderboard.getPlayerScore(alice), 200);
        vm.stopPrank();
    }

    function testMultipleScoreUpdates() public {
        vm.startPrank(alice);
        leaderboard.setPlayerName("Player One");

        // Submit multiple increasing scores
        leaderboard.submitScore(100);
        leaderboard.submitScore(200);
        leaderboard.submitScore(300);
        leaderboard.submitScore(400);

        // Verify only the highest score is kept
        assertEq(leaderboard.getPlayerScore(alice), 400);
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
        vm.startPrank(alice);
        leaderboard.setPlayerName("Player One");
        leaderboard.submitScore(100);
        vm.stopPrank();

        vm.startPrank(bob);
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
        vm.startPrank(alice);
        leaderboard.setPlayerName("Player One");
        leaderboard.submitScore(100);
        vm.stopPrank();

        vm.startPrank(bob);
        leaderboard.setPlayerName("Player Two");
        leaderboard.submitScore(200);
        vm.stopPrank();

        vm.startPrank(charlie);
        leaderboard.setPlayerName("Player Three");
        leaderboard.submitScore(300);
        vm.stopPrank();

        // Update player1's score
        vm.startPrank(alice);
        leaderboard.submitScore(400);
        vm.stopPrank();

        // Verify player1's old score was removed and new score is at the top
        assertEq(leaderboard.getTopScores().length, 3);
        assertEq(leaderboard.getScoreByPosition(0), 400);
        assertEq(leaderboard.getPlayerByPosition(0), alice);
        assertEq(leaderboard.getScoreByPosition(1), 300);
        assertEq(leaderboard.getScoreByPosition(2), 200);
    }

    function testGetTotalScores() public {
        // Initially should be 0
        assertEq(leaderboard.getTotalScores(), 0);

        // Add some scores
        vm.prank(alice);
        leaderboard.submitScore(100);
        assertEq(leaderboard.getTotalScores(), 1);

        vm.prank(bob);
        leaderboard.submitScore(200);
        assertEq(leaderboard.getTotalScores(), 2);

        vm.prank(charlie);
        leaderboard.submitScore(300);
        assertEq(leaderboard.getTotalScores(), 3);

        // Update existing score should not change total
        vm.prank(alice);
        leaderboard.submitScore(150);
        assertEq(leaderboard.getTotalScores(), 3);
    }

    function testSetPlayerNameOnce() public {
        vm.startPrank(alice);

        // First name set should work
        leaderboard.setPlayerName("Alice");
        assertEq(leaderboard.getPlayerName(alice), "Alice");

        // Second name set should be ignored
        leaderboard.setPlayerName("Alice Updated");
        assertEq(leaderboard.getPlayerName(alice), "Alice");

        // Empty name should be ignored
        leaderboard.setPlayerName("");
        assertEq(leaderboard.getPlayerName(alice), "Alice");

        vm.stopPrank();
    }

    function testPlayerNamesAddrOrder() public {
        // Set names in order
        vm.startPrank(alice);
        leaderboard.setPlayerName("Alice");
        vm.stopPrank();

        vm.startPrank(bob);
        leaderboard.setPlayerName("Bob");
        vm.stopPrank();

        vm.startPrank(charlie);
        leaderboard.setPlayerName("Charlie");
        vm.stopPrank();

        // Verify names are stored in order
        assertEq(leaderboard.playerNamesAddr(0), "Alice");
        assertEq(leaderboard.playerNamesAddr(1), "Bob");
        assertEq(leaderboard.playerNamesAddr(2), "Charlie");
    }

    function testGetPlayerNameByPositionWithScores() public {
        // Set names first
        vm.startPrank(alice);
        leaderboard.setPlayerName("Alice");
        leaderboard.submitScore(100);
        vm.stopPrank();

        vm.startPrank(bob);
        leaderboard.setPlayerName("Bob");
        leaderboard.submitScore(300); // Highest score
        vm.stopPrank();

        vm.startPrank(charlie);
        leaderboard.setPlayerName("Charlie");
        leaderboard.submitScore(200);
        vm.stopPrank();

        // Verify getPlayerNameByPosition returns names in score order
        // Bob has highest score (300)
        assertEq(leaderboard.getPlayerNameByPosition(0), "Bob");
        // Charlie has second highest score (200)
        assertEq(leaderboard.getPlayerNameByPosition(1), "Charlie");
        // Alice has lowest score (100)
        assertEq(leaderboard.getPlayerNameByPosition(2), "Alice");

        // Invalid position should return empty string
        assertEq(leaderboard.getPlayerNameByPosition(3), "");
    }

    function testPlayerNamesAddrWithScoreUpdates() public {
        // Set names and initial scores
        vm.startPrank(alice);
        leaderboard.setPlayerName("Alice");
        leaderboard.submitScore(100);
        vm.stopPrank();

        vm.startPrank(bob);
        leaderboard.setPlayerName("Bob");
        leaderboard.submitScore(200);
        vm.stopPrank();

        // Update Alice's score to be highest
        vm.startPrank(alice);
        leaderboard.submitScore(300);
        vm.stopPrank();

        // playerNamesAddr should maintain original order
        assertEq(leaderboard.playerNamesAddr(0), "Alice");
        assertEq(leaderboard.playerNamesAddr(1), "Bob");

        // getPlayerNameByPosition should return in score order
        assertEq(leaderboard.getPlayerNameByPosition(0), "Alice"); // Now highest score
        assertEq(leaderboard.getPlayerNameByPosition(1), "Bob"); // Now lowest score
    }
}
