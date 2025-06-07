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
    // Mapping to store player names
    mapping(address => string) public playerNames;
    // Mapping to store player addresses by name
    mapping(string => address) public playerNameToAddress;

    // Maximum number of scores to keep
    uint256 public constant MAX_SCORES = 100;

    event ScoreSubmitted(address player, uint256 score);
    event PlayerNameSet(address player, string playerName);
    event ScoreRemoved(address player);

    /**
     * @dev Set or update a player's name
     * @param playerName The name to set for the player
     */
    function setPlayerName(string memory playerName) external {
        require(bytes(playerName).length > 0, "Player name cannot be empty");
        require(bytes(playerName).length <= 32, "Player name too long");

        // Remove old name mapping if it exists
        string memory oldName = playerNames[msg.sender];
        if (
            bytes(oldName).length > 0 &&
            keccak256(bytes(oldName)) != keccak256(bytes(playerName))
        ) {
            playerNameToAddress[oldName] = address(0);
        }
        // Update both mappings
        playerNames[msg.sender] = playerName;
        playerNameToAddress[playerName] = msg.sender;

        emit PlayerNameSet(msg.sender, playerName);
    }

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
            uint256 removedScore = scores[scores.length - 1].score;
            scores.pop();
            // Only remove from playerScores if this was their only score
            if (playerScores[removedPlayer] == removedScore) {
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

    /**
     * @dev Get only the scores array (more gas efficient than getTopScores)
     * @return Array of scores in descending order
     */
    function getScores() external view returns (uint256[] memory) {
        Score[] memory allScores = scores;
        uint256[] memory scoreValues = new uint256[](allScores.length);

        for (uint256 i = 0; i < allScores.length; i++) {
            scoreValues[i] = allScores[i].score;
        }

        return scoreValues;
    }

    /**
     * @dev Get score at a specific position in the leaderboard
     * @param position The position in the leaderboard (0-based index)
     * @return The score at the specified position, or 0 if position is invalid
     */
    function getScoreByPosition(
        uint256 position
    ) external view returns (uint256) {
        if (position >= scores.length) {
            return 0;
        }
        return scores[position].score;
    }

    /**
     * @dev Get player address at a specific position in the leaderboard
     * @param position The position in the leaderboard (0-based index)
     * @return The player address at the specified position, or address(0) if position is invalid
     */
    function getPlayerByPosition(
        uint256 position
    ) external view returns (address) {
        if (position >= scores.length) {
            return address(0);
        }
        return scores[position].player;
    }

    /**
     * @dev Get timestamp at a specific position in the leaderboard
     * @param position The position in the leaderboard (0-based index)
     * @return The timestamp at the specified position, or 0 if position is invalid
     */
    function getTimestampByPosition(
        uint256 position
    ) external view returns (uint256) {
        if (position >= scores.length) {
            return 0;
        }
        return scores[position].timestamp;
    }

    /**
     * @dev Get player name at a specific position in the leaderboard
     * @param position The position in the leaderboard (0-based index)
     * @return The player name at the specified position, or empty string if position is invalid
     */
    function getPlayerNameByPosition(
        uint256 position
    ) external view returns (string memory) {
        if (position >= scores.length) {
            return "";
        }
        return playerNames[scores[position].player];
    }

    /**
     * @dev Get all player names from the leaderboard
     * @return Array of player names in descending order of scores
     */
    function getPlayerNames() external view returns (string[] memory) {
        Score[] memory allScores = scores;
        string[] memory names = new string[](allScores.length);

        for (uint256 i = 0; i < allScores.length; i++) {
            names[i] = playerNames[allScores[i].player];
        }

        return names;
    }

    /**
     * @dev Get player names for a specific range of positions
     * @param start The starting position (inclusive)
     * @param end The ending position (exclusive)
     * @return Array of player names in the specified range
     */
    function getPlayerNamesInRange(
        uint256 start,
        uint256 end
    ) external view returns (string[] memory) {
        require(start < end, "Start position must be less than end position");
        require(
            end <= scores.length,
            "End position exceeds leaderboard length"
        );

        uint256 rangeLength = end - start;
        string[] memory names = new string[](rangeLength);

        for (uint256 i = 0; i < rangeLength; i++) {
            names[i] = playerNames[scores[start + i].player];
        }

        return names;
    }

    /**
     * @dev Get a player's name by their address
     * @param player The address of the player
     * @return The player's name, or empty string if not found
     */
    function getPlayerName(
        address player
    ) external view returns (string memory) {
        return playerNames[player];
    }

    /// @notice Get a player's address by their name
    /// @param playerName The name of the player to look up
    /// @return The address associated with the player name, or address(0) if not found
    function getPlayerAddressByName(
        string memory playerName
    ) public view returns (address) {
        return playerNameToAddress[playerName];
    }
}
