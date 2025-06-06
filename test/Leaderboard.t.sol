// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "../src/Leaderboard.sol";

contract LeaderboardTest is Test {
    Leaderboard public leaderboard;
    address public alice = address(0x1);
    address public bob = address(0x2);
    address public charlie = address(0x3);

    function setUp() public {
        leaderboard = new Leaderboard();
        vm.label(alice, "Alice");
        vm.label(bob, "Bob");
        vm.label(charlie, "Charlie");
    }

    function testSubmitScore() public {
        vm.startPrank(alice);
        leaderboard.submitScore(100);
        vm.stopPrank();

        Leaderboard.Score[] memory scores = leaderboard.getTopScores();
        assertEq(scores.length, 1);
        assertEq(scores[0].player, alice);
        assertEq(scores[0].score, 100);
        assertEq(leaderboard.getPlayerScore(alice), 100);
    }

    function testMultipleScores() public {
        // Alice submits score
        vm.startPrank(alice);
        leaderboard.submitScore(100);
        vm.stopPrank();

        // Bob submits higher score
        vm.startPrank(bob);
        leaderboard.submitScore(200);
        vm.stopPrank();

        // Charlie submits middle score
        vm.startPrank(charlie);
        leaderboard.submitScore(150);
        vm.stopPrank();

        Leaderboard.Score[] memory scores = leaderboard.getTopScores();
        assertEq(scores.length, 3);
        assertEq(scores[0].player, bob);
        assertEq(scores[0].score, 200);
        assertEq(scores[1].player, charlie);
        assertEq(scores[1].score, 150);
        assertEq(scores[2].player, alice);
        assertEq(scores[2].score, 100);

        // Verify player scores
        assertEq(leaderboard.getPlayerScore(alice), 100);
        assertEq(leaderboard.getPlayerScore(bob), 200);
        assertEq(leaderboard.getPlayerScore(charlie), 150);
    }

    function testUpdateScore() public {
        // Alice submits initial score
        vm.startPrank(alice);
        leaderboard.submitScore(100);
        vm.stopPrank();

        // Alice tries to update with lower score (should not update)
        vm.startPrank(alice);
        leaderboard.submitScore(50);
        vm.stopPrank();

        // Verify score didn't change
        assertEq(leaderboard.getPlayerScore(alice), 100);

        // Alice updates with higher score
        vm.startPrank(alice);
        leaderboard.submitScore(300);
        vm.stopPrank();

        // Verify score updated
        assertEq(leaderboard.getPlayerScore(alice), 300);

        Leaderboard.Score[] memory scores = leaderboard.getTopScores();
        assertEq(scores.length, 1);
        assertEq(scores[0].player, alice);
        assertEq(scores[0].score, 300);
    }

    function test_RevertWhen_ScoreIsZero() public {
        vm.startPrank(alice);
        vm.expectRevert("Score must be greater than 0");
        leaderboard.submitScore(0);
        vm.stopPrank();
    }

    function testMaxScores() public {
        // Submit scores from 100 different players
        for (uint256 i = 1; i <= 100; i++) {
            address player = address(uint160(i));
            vm.startPrank(player);
            leaderboard.submitScore(i * 10);
            vm.stopPrank();
        }

        // Verify we have exactly MAX_SCORES
        assertEq(leaderboard.getTopScores().length, 100);

        // Submit a new score that should make it to the leaderboard
        address newPlayer = address(0x999);
        vm.startPrank(newPlayer);
        leaderboard.submitScore(500); // This should be in the middle
        vm.stopPrank();

        // Verify we still have exactly MAX_SCORES
        assertEq(leaderboard.getTopScores().length, 100);

        // Verify the lowest score was removed
        Leaderboard.Score[] memory scores = leaderboard.getTopScores();
        assertEq(scores[99].score, 20); // The lowest score should be 20 (from player 2)
    }

    function testGetScores() public {
        // Submit scores from multiple players
        vm.startPrank(alice);
        leaderboard.submitScore(100);
        vm.stopPrank();

        vm.startPrank(bob);
        leaderboard.submitScore(200);
        vm.stopPrank();

        vm.startPrank(charlie);
        leaderboard.submitScore(150);
        vm.stopPrank();

        // Get only the scores
        uint256[] memory scoreValues = leaderboard.getScores();

        // Verify array length
        assertEq(scoreValues.length, 3);

        // Verify scores are in descending order
        assertEq(scoreValues[0], 200); // Bob's score
        assertEq(scoreValues[1], 150); // Charlie's score
        assertEq(scoreValues[2], 100); // Alice's score
    }

    function testGetScoreByPosition() public {
        // Submit scores from multiple players
        vm.startPrank(alice);
        leaderboard.submitScore(100);
        vm.stopPrank();

        vm.startPrank(bob);
        leaderboard.submitScore(200);
        vm.stopPrank();

        vm.startPrank(charlie);
        leaderboard.submitScore(150);
        vm.stopPrank();

        // Test valid positions
        assertEq(leaderboard.getScoreByPosition(0), 200); // First place (Bob)
        assertEq(leaderboard.getScoreByPosition(1), 150); // Second place (Charlie)
        assertEq(leaderboard.getScoreByPosition(2), 100); // Third place (Alice)

        // Test invalid position
        assertEq(leaderboard.getScoreByPosition(3), 0); // Out of bounds
    }

    function testGetPlayerAndTimestampByPosition() public {
        // Submit scores from multiple players
        vm.startPrank(alice);
        leaderboard.submitScore(100);
        vm.stopPrank();

        vm.startPrank(bob);
        leaderboard.submitScore(200);
        vm.stopPrank();

        vm.startPrank(charlie);
        leaderboard.submitScore(150);
        vm.stopPrank();

        // Test valid positions for player addresses
        assertEq(leaderboard.getPlayerByPosition(0), bob); // First place
        assertEq(leaderboard.getPlayerByPosition(1), charlie); // Second place
        assertEq(leaderboard.getPlayerByPosition(2), alice); // Third place

        // Test invalid position for player address
        assertEq(leaderboard.getPlayerByPosition(3), address(0)); // Out of bounds

        // Test valid positions for timestamps
        uint256 firstTimestamp = leaderboard.getTimestampByPosition(0);
        uint256 secondTimestamp = leaderboard.getTimestampByPosition(1);
        uint256 thirdTimestamp = leaderboard.getTimestampByPosition(2);

        // Verify timestamps are in descending order (since scores are submitted in sequence)
        assertTrue(firstTimestamp <= secondTimestamp);
        assertTrue(secondTimestamp <= thirdTimestamp);
        assertTrue(firstTimestamp > 0);
        assertTrue(secondTimestamp > 0);
        assertTrue(thirdTimestamp > 0);

        // Test invalid position for timestamp
        assertEq(leaderboard.getTimestampByPosition(3), 0); // Out of bounds
    }
}
