// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract Leaderboard {
    struct Score {
        address player;
        uint256 score;
        uint256 timestamp;
    }

    // Array of scores for the game
    Score[] public scores;

    // Mapping to track player's current score
    mapping(address => uint256) public playerScores;

    // Maximum number of scores to keep
    uint256 public constant MAX_SCORES = 100;

    event ScoreSubmitted(address player, uint256 score);
    event ScoreRemoved(address player);

    /**
     * @dev Submit a new score for the game
     * @param score The player's score
     */
    function submitScore(uint256 score) external {
        require(score > 0, "Score must be greater than 0");

        uint256 currentScore = playerScores[msg.sender];

        // Only update if new score is higher than current score
        if (score <= currentScore) {
            return;
        }

        // If player already has a score, remove it first
        if (currentScore > 0) {
            _removePlayerScore(msg.sender);
        }

        // Add new score
        scores.push(
            Score({
                player: msg.sender,
                score: score,
                timestamp: block.timestamp
            })
        );

        // Update player's current score
        playerScores[msg.sender] = score;

        // Sort scores in descending order
        _sortScores();

        // Trim scores if exceeding MAX_SCORES
        if (scores.length > MAX_SCORES) {
            // Remove the lowest score
            address removedPlayer = scores[scores.length - 1].player;
            scores.pop();
            // Only remove from playerScores if this was their only score
            if (
                playerScores[removedPlayer] == scores[scores.length - 1].score
            ) {
                playerScores[removedPlayer] = 0;
            }
        }

        emit ScoreSubmitted(msg.sender, score);
    }

    /**
     * @dev Get top scores for the game
     * @return Array of top scores
     */
    function getTopScores() external view returns (Score[] memory) {
        return scores;
    }

    /**
     * @dev Get a player's current score
     * @param player The address of the player
     * @return The player's score, or 0 if no score exists
     */
    function getPlayerScore(address player) external view returns (uint256) {
        return playerScores[player];
    }

    /**
     * @dev Remove a player's score
     * @param player The address of the player to remove
     */
    function _removePlayerScore(address player) internal {
        for (uint256 i = 0; i < scores.length; i++) {
            if (scores[i].player == player) {
                // Move the last element to the current position
                scores[i] = scores[scores.length - 1];
                scores.pop();
                emit ScoreRemoved(player);
                break;
            }
        }
    }

    /**
     * @dev Sort scores in descending order using insertion sort
     */
    function _sortScores() internal {
        for (uint256 i = 1; i < scores.length; i++) {
            Score memory current = scores[i];
            uint256 j = i;
            while (j > 0 && scores[j - 1].score < current.score) {
                scores[j] = scores[j - 1];
                j--;
            }
            scores[j] = current;
        }
    }
}
